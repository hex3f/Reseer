/**
 * serverv_cleaned.js
 * ---------------------------------
 * 本地纯静态文件服务器
 *
 * 特点：
 * - 只读本地目录
 * - 不联网
 * - 不回源
 * - 不代理
 *
 * 用途：
 * - 提供 UI / 前端静态资源
 */

'use strict';

const fs = require('fs');
const http = require('http');
const StaticServer = require('node-static').Server;

// 从命令行获取静态目录
const rootDir = process.argv[2];

if (!rootDir) {
  console.error('未指定静态目录');
  process.exit(1);
}

// 确保目录存在
if (!fs.existsSync(rootDir)) {
  fs.mkdirSync(rootDir, { recursive: true });
}

// 创建静态文件服务
const fileServer = new StaticServer(rootDir, {
  headers: {
    'Cache-Control': 'no-cache, no-store'
  }
});

const PORT = 9991;

// HTTP 服务
const server = http.createServer((req, res) => {
  req.on('end', () => {
    fileServer.serve(req, res, (err) => {
      if (err) {
        console.error('静态文件错误:', err.message);
        res.writeHead(err.status, err.headers);
        res.end();
      }
    });
  }).resume();
});

server.listen(PORT, () => {
  console.log('静态服务器运行在 http://localhost:' + PORT);
});
