#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const baseDir = path.resolve(__dirname, '..', '..');
const sitesEnabledDir = path.join(baseDir, 'sites-enabled');
const outputPath = path.join(__dirname, 'services.json');

function readFilesRecursively(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  let files = [];

  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      files = files.concat(readFilesRecursively(fullPath));
      continue;
    }

    if (entry.isFile() && (entry.name.endsWith('.conf') || entry.name.endsWith('.locations'))) {
      files.push(fullPath);
    }
  }

  return files;
}

function parseServiceName(route) {
  const cleaned = route.replace(/^\/+|\/+$/g, '');
  if (!cleaned) return 'Home';
  return cleaned
    .split('/')
    .filter(Boolean)
    .map((part) => part
      .split(/[-_]+/)
      .filter(Boolean)
      .map((segment) => segment.charAt(0).toUpperCase() + segment.slice(1))
      .join(' '))
    .join(' ');
}

function iconForService(serviceName, sourceFile = '') {
  const source = sourceFile.toLowerCase();
  const lower = serviceName.toLowerCase();

  if (source.includes('alertmanager') || lower.includes('alertmanager')) return 'alertmanager';
  if (source.includes('authentik') || lower.includes('authentik')) return 'authentik';
  if (source.includes('grafana') || lower.includes('grafana')) return 'grafana';
  if (source.includes('jenkins') || lower.includes('jenkins')) return 'jenkins';
  if (source.includes('portainer') || lower.includes('portainer')) return 'portainer';
  if (source.includes('prometheus') || lower.includes('prometheus')) return 'prometheus';
  if (source.includes('nginx-exporter') || lower.includes('exporter')) return 'prometheus';

  return 'app';
}

function extractBlocks(content) {
  const blocks = [];
  const lines = content.split(/\r?\n/);

  for (let i = 0; i < lines.length; i += 1) {
    const locationMatch = lines[i].match(/^\s*location\s+(?:([=~^*])\s*)?(.+?)\s*\{/);
    if (!locationMatch) continue;

    const modifier = locationMatch[1] || '';
    let route = locationMatch[2].trim();
    if (modifier === '~') {
      route = route.replace(/^\^/, '').replace(/\(\.\*\)\$$/, '');
    }
    let depth = 0;
    const blockLines = [];

    for (let j = i; j < lines.length; j += 1) {
      const current = lines[j];
      depth += (current.match(/\{/g) || []).length;
      depth -= (current.match(/\}/g) || []).length;
      blockLines.push(current);
      if (depth === 0) {
        i = j;
        break;
      }
    }

    blocks.push({ route, text: blockLines.join('\n') });
  }

  return blocks;
}

function resolveUpstream(blockText) {
  const setMap = new Map();

  const setRegex = /^\s*set\s+\$([a-zA-Z0-9_]+)\s+([^;]+);/gm;
  let setMatch = null;
  while ((setMatch = setRegex.exec(blockText)) !== null) {
    setMap.set(setMatch[1], setMatch[2].trim());
  }

  const proxyPassMatch = blockText.match(/^\s*proxy_pass\s+([^;]+);/m);
  if (!proxyPassMatch) return null;

  let target = proxyPassMatch[1].trim();
  const varMatch = target.match(/^\$([a-zA-Z0-9_]+)$/);
  if (varMatch && setMap.has(varMatch[1])) {
    target = setMap.get(varMatch[1]);
  }

  return target;
}

function parseDirectLink(upstream, route) {
  try {
    const url = new URL(upstream);
    const protocol = url.protocol.replace(':', '');
    const host = url.hostname;
    const port = url.port || (protocol === 'https' ? '443' : '80');

    return {
      protocol,
      host,
      port,
      path: route,
    };
  } catch (error) {
    return null;
  }
}

function collectServices() {
  if (!fs.existsSync(sitesEnabledDir)) {
    throw new Error('Directory not found: ' + sitesEnabledDir);
  }

  const files = readFilesRecursively(sitesEnabledDir);
  const services = [];

  for (const file of files) {
    const content = fs.readFileSync(file, 'utf8');
    const blocks = extractBlocks(content);

    for (const block of blocks) {
      if (!block.route.startsWith('/')) continue;
      if (block.route === '/' || block.route === '/404.html' || block.route === '/50x.html' || block.route.includes('unavailable')) {
        continue;
      }

      const hasProxy = /^\s*proxy_pass\s+/m.test(block.text);
      if (!hasProxy) continue;

      const normalizedRoute = block.route.endsWith('/') ? block.route : block.route + '/';
      const serviceName = parseServiceName(normalizedRoute);
      const upstream = resolveUpstream(block.text);
      const direct = upstream ? parseDirectLink(upstream, normalizedRoute) : null;

      const sourceFile = path.relative(sitesEnabledDir, file);

      services.push({
        name: serviceName,
        slug: normalizedRoute.replace(/^\/+|\/+$/g, '').replace(/\//g, '-'),
        route: normalizedRoute,
        proxyUrl: normalizedRoute,
        sourceFile,
        icon: iconForService(serviceName, path.basename(file, path.extname(file))),
        upstream: upstream || null,
        direct,
      });
    }
  }

  const unique = [];
  const seen = new Set();
  for (const service of services) {
    const key = service.route + '|' + (service.upstream || '');
    if (seen.has(key)) continue;
    seen.add(key);
    unique.push(service);
  }

  unique.sort((a, b) => a.name.localeCompare(b.name));
  return unique;
}

function writeCatalog() {
  const services = collectServices();
  const payload = {
    generatedAt: new Date().toISOString(),
    serviceCount: services.length,
    services,
  };

  fs.writeFileSync(outputPath, JSON.stringify(payload, null, 2) + '\n', 'utf8');
  process.stdout.write(`Generated ${services.length} services at ${outputPath}\n`);
}

writeCatalog();
