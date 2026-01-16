/**
 * main_cleaned.js
 * ---------------------------------
 * Electron 主进程入口（总控）
 *
 * 作用：
 * 1. 启动两个子进程服务器
 *    - serverv.js : 本地纯静态资源服务器（9991）
 *    - servers.js : 本地优先 + nieo.cc 回源服务器（9990）
 * 2. 接收 servers.js 发来的 notfound 消息
 * 3. 转发给 Electron 渲染进程
 */

'use strict';

const { fork } = require('child_process');
const path = require('path');

// 本地资源根目录（示例）
const PUBLIC_DIR = path.join(__dirname, 'public');
const NIEO_ASSET_DIR = path.join(__dirname, 'nieoasset');

// 启动纯本地静态服务器
const staticServer = fork(
  path.join(__dirname, 'serverv.js'),
  [PUBLIC_DIR]
);

// 启动 nieo 资源调度服务器
const nieoServer = fork(
  path.join(__dirname, 'servers.js'),
  [NIEO_ASSET_DIR]
);

// 监听 nieoServer 的缺失资源通知
nieoServer.on('message', (msg) => {
  if (msg && msg.type === 'notfound') {
    console.log('[NIEO NOT FOUND]', msg.data);
    // 在 Electron 项目中，这里通常会：
    // mainWindow.webContents.send('notfound', msg.data);
  }
});

console.log('main_cleaned.js 启动完成');
