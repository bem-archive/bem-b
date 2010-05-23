var fs = require('file'),
    os = require('os'),
    dir = fs.path(module.path).dirname(),
    mergeDecls = require('bem/commands/decl/merge').mergeDecls;

exports.techModule = module;

exports.bemBuild = function (prefixes, outputDir, outputName) {
    var _this = this,
        decl;
    this.filterExists(prefixes)
        .forEach(function (file) {
            var json = os.command(['xsltproc ', dir.join('xmlxsl2decl.xsl'), file].join(' '));
            decl = mergeDecls(decl, JSON.decode(json));
        });
    outputDir
        .join(outputName + '.' + this.getTechName())
        .write('exports.blocks = ' + JSON.encode(decl, null, 4) + ';\n');
    return this;
};

exports.filterExists = function (prefixes) {
    var _this = this,
        res = [];
    ['b.xsl'].forEach(function(postfix){
        prefixes.forEach(function (prefix) {
            var file = fs.path(prefix + '.' + postfix);
            file.exists() && res.push(file);
        });
    });
    return res;
};
