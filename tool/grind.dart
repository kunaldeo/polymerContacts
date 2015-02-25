// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as path;

final Directory BUILD_DIR = new Directory('build');

final RegExp _binaryFileTypes = new RegExp(
    r'\.(jpe?g|png|gif|ico|svg|ttf|eot|woff|woff2)$', caseSensitive: false);

void main([List<String> args]) {
  task('init', init);
  task('build', buildTemplates, ['init']);
//  task('update-gh-pages', updateGhPages, ['init']);
//  task('test', testGenerators, ['init']);
  task('clean', clean);

  startGrinder(args);
}

/**
 * Do any necessary build set up.
 */
void init(GrinderContext context) {
  // Verify we're running in the project root.
  if (!getDir('template-dir').existsSync() || !getFile('pubspec.yaml').existsSync()) {
    context.fail('This script must be run from the project root.\n Please copy your template in template-dir folder.');
  }
}

/**
 * Concatenate the template files into data files that the generators can
 * consume.
 */
void buildTemplates(GrinderContext context) {
  _concatenateFiles(
      context,
      getDir('template-dir'),
      getFile('src/template_data.dart'));
}

/**
 * Delete all generated artifacts.
 */
void clean(GrinderContext context) {
  // Delete the build/ dir.
  deleteEntity(BUILD_DIR, context);
}

void _concatenateFiles(GrinderContext context, Directory src, File target) {
  context.log('Creating ${target.path}');

  List<String> results = [];

  _traverse(src, '', results);

  String str = results.map((s) => '  ${_toStr(s)}').join(',\n');

  target.writeAsStringSync("""
// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

List<String> templateData = [
${str}
];
""");
}

String _toStr(String s) {
  if (s.contains('\n')) {
    return '"""${s}"""';
  } else {
    return '"${s}"';
  }
}

void _traverse(Directory dir, String root, List<String> results) {
  var files = _listSync(dir, recursive: false, followLinks: false);
  for (FileSystemEntity entity in files) {
    String name = path.basename(entity.path);

    if (entity is Link) continue;

    if (name == 'pubspec.lock') continue;
    if (name.startsWith('.') && name != '.gitignore') continue;

    if (entity is Directory) {
      _traverse(entity, '${root}${name}/', results);
    } else {
      File file = entity;
      String fileType = _isBinaryFile(name) ? 'binary' : 'text';
      String data = CryptoUtils.bytesToBase64(
          file.readAsBytesSync(), addLineSeparator: true);

      results.add('${root}${name}');
      results.add(fileType);
      results.add(data);
    }
  }
}

/**
 * Returns true if the given [filename] matches common image file name patterns.
 */
bool _isBinaryFile(String filename) => _binaryFileTypes.hasMatch(filename);

File _locateDartFile(File file) {
  if (file.path.endsWith('.dart')) return file;

  return _listSync(file.parent).firstWhere(
      (f) => f.path.endsWith('.dart'), orElse: () => null);
}

/**
 * Return the list of children for the given directory. This list is normalized
 * (by sorting on the file path) in order to prevent large merge diffs in the
 * generated template data files.
 */
List<FileSystemEntity> _listSync(Directory dir,
    {bool recursive: false, bool followLinks: true}) {
  List<FileSystemEntity> results = dir.listSync(
      recursive: recursive, followLinks: followLinks);
  results.sort((entity1, entity2) => entity1.path.compareTo(entity2.path));
  return results;
}
