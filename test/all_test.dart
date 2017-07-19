import 'package:symbol_table/symbol_table.dart';
import 'package:test/test.dart';

main() {
  SymbolTable<int> scope;

  setUp(() {
    scope = new SymbolTable<int>(values: {'one': 1});
  });

  test('starter values', () {
    expect(scope['one'].value, 1);
  });

  test('add', () {
    var two = scope.add('two', value: 2);
    expect(two.value, 2);
    expect(two.isImmutable, isFalse);
  });

  test('put', () {
    var one = scope.resolve('one');
    var child = scope.createChild();
    var three = child.put('one', 3);
    expect(three.value, 3);
    expect(three, one);
  });

  test('private', () {
    var three = scope.add('three', value: 3)..markAsPrivate();
    expect(three.isPrivate, true);
    expect(scope.allVariables, contains(three));
    expect(scope.allPublicVariables, isNot(contains(three)));
  });

  test('constants', () {
    var two = scope.add('two', value: 2, constant: true);
    expect(two.value, 2);
    expect(two.isImmutable, isTrue);
    expect(() => scope['two'] = 3, throwsStateError);
  });

  test('lock', () {
    expect(scope['one'].isImmutable, isFalse);
    scope['one'].lock();
    expect(scope['one'].isImmutable, isTrue);
    expect(() => scope['one'] = 2, throwsStateError);
  });

  test('child', () {
    expect(scope.createChild().createChild().resolve('one').value, 1);
  });

  test('clone', () {
    var child = scope.createChild();
    var clone = child.clone();
    expect(clone.resolve('one'), child.resolve('one'));
    expect(clone.parent, child.parent);
  });

  test('fork', () {
    var fork = scope.fork();
    scope.put('three', 3);

    expect(scope.resolve('three'), isNotNull);
    expect(fork.resolve('three'), isNull);
  });

  test('remove', () {
    var one = scope.remove('one');
    expect(one.value, 1);

    expect(scope.resolve('one'), isNull);
  });

  test('root', () {
    expect(scope.isRoot, isTrue);
    expect(scope.root, scope);

    var child = scope
        .createChild()
        .createChild()
        .createChild()
        .createChild()
        .createChild()
        .createChild()
        .createChild();
    expect(child.isRoot, false);
    expect(child.root, scope);
  });
}
