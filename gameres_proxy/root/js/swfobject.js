/**
 * SWFObject v1.5 简化版
 * 用于嵌入Flash SWF文件
 */
function SWFObject(swf, id, w, h, ver, c, quality, xiRedirectUrl, redirectUrl, detectKey) {
    this.params = {};
    this.variables = {};
    this.attributes = [];
    
    if (swf) this.setAttribute('swf', swf);
    if (id) this.setAttribute('id', id);
    if (w) this.setAttribute('width', w);
    if (h) this.setAttribute('height', h);
    if (ver) this.setAttribute('version', ver);
    if (c) this.addParam('bgcolor', c);
    
    this.addParam('quality', quality || 'high');
    this.addParam('allowScriptAccess', 'always');
}

SWFObject.prototype.addParam = function(name, value) {
    this.params[name] = value;
};

SWFObject.prototype.getParams = function() {
    return this.params;
};

SWFObject.prototype.addVariable = function(name, value) {
    this.variables[name] = value;
};

SWFObject.prototype.getVariable = function(name) {
    return this.variables[name];
};

SWFObject.prototype.getVariables = function() {
    return this.variables;
};

SWFObject.prototype.setAttribute = function(name, value) {
    this.attributes[name] = value;
};

SWFObject.prototype.getAttribute = function(name) {
    return this.attributes[name];
};

SWFObject.prototype.getVariablePairs = function() {
    var pairs = [];
    for (var key in this.variables) {
        pairs.push(key + '=' + encodeURIComponent(this.variables[key]));
    }
    return pairs;
};

SWFObject.prototype.write = function(elementId) {
    var container = document.getElementById(elementId);
    if (!container) {
        console.error('[SWFObject] Container not found:', elementId);
        return false;
    }
    
    var swf = this.getAttribute('swf');
    var id = this.getAttribute('id') || 'flash_' + Math.random().toString(36).substr(2, 9);
    var width = this.getAttribute('width') || '100%';
    var height = this.getAttribute('height') || '100%';
    
    // 构建参数字符串
    var flashvars = this.getVariablePairs().join('&');
    
    // 使用 embed 标签（更简单，兼容性更好）
    var html = '<embed src="' + swf + '" ';
    html += 'id="' + id + '" name="' + id + '" ';
    html += 'width="' + width + '" height="' + height + '" ';
    html += 'type="application/x-shockwave-flash" ';
    html += 'pluginspage="http://www.macromedia.com/go/getflashplayer" ';
    html += 'style="display:block;" ';  // 确保块级显示
    
    for (var param in this.params) {
        html += param + '="' + this.params[param] + '" ';
    }
    
    if (flashvars) {
        html += 'flashvars="' + flashvars + '" ';
    }
    
    html += '>';
    
    container.innerHTML = html;
    console.log('[SWFObject] Flash embedded:', swf, 'size:', width, 'x', height);
    
    return true;
};

// 检测Flash版本
SWFObject.getPlayerVersion = function() {
    var version = { major: 0, minor: 0, rev: 0 };
    
    try {
        // IE
        var axo = new ActiveXObject('ShockwaveFlash.ShockwaveFlash');
        var versionStr = axo.GetVariable('$version');
        var versionArray = versionStr.split(' ')[1].split(',');
        version.major = parseInt(versionArray[0], 10);
        version.minor = parseInt(versionArray[1], 10);
        version.rev = parseInt(versionArray[2], 10);
    } catch (e) {
        // 非IE
        if (navigator.plugins && navigator.plugins['Shockwave Flash']) {
            var desc = navigator.plugins['Shockwave Flash'].description;
            var matches = desc.match(/(\d+)\.(\d+)\s*r(\d+)/);
            if (matches) {
                version.major = parseInt(matches[1], 10);
                version.minor = parseInt(matches[2], 10);
                version.rev = parseInt(matches[3], 10);
            }
        }
    }
    
    return version;
};

console.log('[SWFObject] Loaded');
