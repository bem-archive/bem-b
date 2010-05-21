var fs = require('file'),
    os = require('os'),
    dir = fs.path(module.path).dirname();

exports.techModule = module;

exports.bemBuild = function (prefixes, outputDir, outputName) {
    var content = '';
    this
        .buildXsl(
            prefixes,
            outputDir,
            outputName,
            this.buildBPreXsl(prefixes, outputDir, outputName))
        .forEach(
            function (file) { content += this.outFile(file) },
            this);
    outputDir.join(outputName + '.xsl').write(
        fs.read(dir.join('xsl.template'))
            .replace('<!-- {{ ALL xsl }} -->', content));
};

exports.buildBPreXsl = function (prefixes, outputDir, outputName) {
    var content = '';
    prefixes.forEach(function (prefix) {
        var prefix = fs.path(prefix),
            xsl = fs.path(prefix + '.b.xsl');
        if (xsl.exists()) {
            var name = prefix.basename(),
                b2xsl = prefix.dirname().join('/.' + name +'.b2xsl.xsl');
                preXsl = prefix.dirname().join('/.' + name +'.b-pre.xsl');
            os.command(['xsltproc -o ' + b2xsl, dir.join('b2xsl.xsl'), xsl].join(' '));
            os.command(['xsltproc -o ' + preXsl, dir.join('xsl-compiler-pre.xsl'), b2xsl].join(' '));
            content += this.outFile(preXsl.from(outputDir));
        }
    }, this);
    return outputDir.join('.' + outputName + '.b-pre.xsl').write(
            fs.read(dir.join('b-pre.xsl.template'))
                .replace('<!-- {{ ALL b-pre }} -->', content));
};

exports.buildXsl = function (prefixes, outputDir, outputName, allPreXsl) {
    var xsls = [];
    prefixes.forEach(function (prefix) {
        var prefix = fs.path(prefix),
            name = prefix.basename(),
            pre = prefix.dirname().join('/.' + name +'.'),
            xsl = fs.path(pre + 'b2xsl.xsl');
        if (xsl.exists()) {
            var tmp1 = fs.path(pre + 'tmp1.xsl'),
                tmp2 = fs.path(pre + 'tmp2.xsl'),
                preXsl = fs.path(pre + 'b-pre.xsl');
                res = fs.path(pre + outputName + '.xsl');

            os.command(['cp', xsl, tmp1]);
            fs.touch(tmp2);
            var i = 0;
            while (os.command(['diff', '-q', tmp1, tmp2]) != '') {
                os.command(['cp', tmp1, tmp2]);
                os.command(['cp', tmp1, pre + 'xsl.' + (i++)]);
                os.command(['xsltproc -o ' + tmp1, allPreXsl, tmp2].join(' '));

                os.command(['xsltproc -o ' + preXsl, dir.join('xsl-compiler-post.xsl'), tmp1].join(' '));
                os.command(['xsltproc -o ' + preXsl, dir.join('xsl-compiler-pre.xsl'), preXsl].join(' '));
            }
            os.command(['xsltproc -o ' + res, dir.join('xsl-compiler-post.xsl'), tmp1].join(' '));
            //os.command(['rm', tmp1, tmp2, xsl]);
            xsls.push(res.from(outputDir));
        }
    });
    return xsls;
};

function indent(level) {
    var indent = new Array(level + 1).join('    ');
    return function(s) { return (s && indent) + s }
}

exports.newFileContent = function (vars) {
    return [
        '<?xml version="1.0" encoding="utf-8"?>',
        '<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"',
        '    xmlns:bb="bem-b" xmlns:b="bem-b:block" xmlns:e="bem-b:elem" xmlns:m="bem-b:mod" xmlns:mix="bem-b:mix"',
        '    xmlns:tb="bem-b:template:block" xmlns:te="bem-b:template:elem" xmlns:tm="bem-b:template:mod" xmlns:mode="bem-b:template:mode"',
        '    exclude-result-prefixes="tb te tm mode b e m mix">\n',

        '    <tb:' + vars.BlockName + '>',

        [
            vars.ElemName? '<te:' + vars.ElemName + '>\n' : '',
            '    <mode:tag></mode:tag>\n',
            '    <mode:content></mode:content>\n',
            vars.ElemName? '</te:' + vars.ElemName + '>\n' : ''
        ].map(indent(vars.ElemName? 2 : 1)).join('') +

        '    </tb:' + vars.BlockName + '>',

        '\n</xsl:stylesheet>\n'
    ].join('\n');
};

exports.outFile = function (file) {
    return '<xsl:import href="' + file + '"/>\n';
};
