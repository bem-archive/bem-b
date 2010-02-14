var fs = require('file'),
    os = require('os'),
    dir = fs.path(module.path).dirname();

exports.outFile = function (file) {
    return '<xsl:import href="' + file + '"/>\n';
};

exports.outPrefixes = function (prefixes, outputDir, outputName) {
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
                preXsl = prefix.dirname().join('/.' + name +'.b-pre.xsl');
            os.command(['xsltproc -o ' + preXsl, dir.join('xsl-compiler-pre.xsl'), xsl].join(' '));
            content += this.outFile(preXsl.from(outputDir));
        }
    }, this);
    return outputDir.join('.' + outputName + '.b-pre.xsl').write(
            fs.read(dir.join('b-pre.xsl.template'))
                .replace('<!-- {{ ALL b-pre }} -->', content));
};

exports.buildXsl = function (prefixes, outputDir, outputName, preXsl) {
    var xsls = [];
    prefixes.forEach(function (prefix) {
        var prefix = fs.path(prefix),
            xsl = fs.path(prefix + '.b.xsl');
        if (xsl.exists()) {
            var name = prefix.basename(),
                pre = prefix.dirname().join('/.' + name +'.'),
                tmp1 = fs.path(pre + 'tmp1.xsl'),
                tmp2 = fs.path(pre + 'tmp2.xsl'),
                res = fs.path(pre + outputName + '.xsl');

            os.command(['cp', xsl, tmp1]);
            fs.touch(tmp2);
            while (os.command(['diff', '-q', tmp1, tmp2]) != '') {
                os.command(['cp', tmp1, tmp2]);
                os.command(['xsltproc -o ' + tmp1, preXsl, tmp2].join(' '));
            }
            os.command(['xsltproc -o ' + res, dir.join('xsl-compiler-post.xsl'), tmp1].join(' '));
            os.command(['rm', tmp1, tmp2]);
            xsls.push(res.from(outputDir));
        }
    });
    return xsls;
};
