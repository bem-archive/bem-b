exports.techModule = module;

exports.outFile = function (file) {
    return '@import ' + file + '\n';
};

exports.newFileContent = function (vars) {
    return [
        '#{$prefix}',
        '  &' + vars.BlockName,
        (vars.ElemName? '    &__' + vars.ElemName : ''),
        (vars.ModVal?
            (vars.ElemName? '  ' : '') + '    &_' + vars.ModName + '_' + vars.ModVal :
            ''),
         '    ' + (vars.ElemName? '  ' : '') + (vars.ModVal? '  ' : '') + '/* ... */'
        ].filter(function(s){ return !!s }).join('\n') + '\n';
};
