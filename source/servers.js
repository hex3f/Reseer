/**
 * servers_cleaned.js
 * ---------------------------------
 * NIEO 资源调度服务器（核心）
 *
 * 规则：
 * 1. 特定路径 → 强制代理到 www.nieo.cc
 * 2. 其它路径：
 *    - 本地存在 → 本地返回
 *    - 本地不存在 → 从 www.nieo.cc 回源
 *
 * 端口：9990
 */

'use strict';

const http = require('http');
const https = require('https');
const url = require('url');
const fs = require('fs');
const path = require('path');
const StaticServer = require('node-static').Server;

const REMOTE_HOST = 'www.nieo.cc';
const ROOT_DIR = process.argv[2];

if (!ROOT_DIR) {
  console.error('未指定 nieoasset 目录');
  process.exit(1);
}

// 确保目录存在
if (!fs.existsSync(ROOT_DIR)) {
  fs.mkdirSync(ROOT_DIR, { recursive: true });
}

// 本地静态服务
const fileServer = new StaticServer(ROOT_DIR, {
  headers: { 'Cache-Control': 'no-cache, no-store' }
});

const PORT = 9990;

function isForceProxy(pathname) {
  return (
    pathname.startsWith('/dll') ||
    pathname.endsWith('PetFightDLL.swf') ||
    pathname.startsWith('/public/dist/')
  );
}

const server = http.createServer((req, res) => {
  const parsed = url.parse(req.url);
  const pathname = parsed.pathname || '';
  const search = parsed.search || '';

  // 强制代理规则
  if (isForceProxy(pathname)) {
    const options = {
      hostname: REMOTE_HOST,
      path: pathname + search,
      method: req.method,
      headers: { ...req.headers, host: REMOTE_HOST }
    };

    const proxyReq = https.request(options, (proxyRes) => {
      res.writeHead(proxyRes.statusCode, proxyRes.headers);
      proxyRes.pipe(res);
    });

    req.pipe(proxyReq);
    return;
  }

  // 本地优先
  const localFile = path.join(ROOT_DIR, pathname);

  fs.access(localFile, fs.constants.F_OK, (err) => {
    if (err) {
      // 本地不存在 → 回源
      const options = {
        hostname: REMOTE_HOST,
        path: pathname + search,
        method: req.method,
        headers: { ...req.headers, host: REMOTE_HOST }
      };

      const remoteReq = https.request(options, (remoteRes) => {
        if (remoteRes.statusCode === 404) {
          process.send?.({ type: 'notfound', data: pathname });
        }

        res.writeHead(remoteRes.statusCode, remoteRes.headers);
        remoteRes.pipe(res);
      });

      req.pipe(remoteReq);
      return;
    }

    // 本地存在 → 静态返回
    req.on('end', () => {
      fileServer.serve(req, res);
    }).resume();
  });
});

server.listen(PORT, () => {
  console.log('NIEO 服务器运行在 http://localhost:' + PORT);
});
