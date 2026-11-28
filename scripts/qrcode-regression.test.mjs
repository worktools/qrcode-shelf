import assert from 'node:assert/strict';
import JsBarcode from 'jsbarcode';

test('updated barcode package still produces CODE128 binary encoding', () => {
  const host = {};
  JsBarcode(host, '1234567890', { format: 'CODE128' });
  assert.equal(host.encodings[0].text, '1234567890');
  assert.match(host.encodings[0].data, /^[01]+$/);
});
import test from 'node:test';
import * as clt from '../js-out/calcit.core.mjs';
import { store, read_codes, Op, BarcodeFormat, plugin_state_op, legacy_truthy_$q_ } from '../js-out/app.schema.mjs';
import { updater } from '../js-out/app.updater.mjs';
import { comp_container } from '../js-out/app.comp.container.mjs';
import { new_reel, Control } from '../js-out/reel.typed.mjs';
import { make_string } from '../js-out/respo.render.html.mjs';
import { with_memo_frame } from '../js-out/respo.memo.mjs';

const tags = clt.init_tags(['add-code', 'touch-code', 'toggle-barcode', 'note-code', 'code-format', 'remove-code', 'id', 'note', 'format', 'gs1-128', 'codes', 'code', 'pointer', 'time', 'barcode?', 'barcode-format']);
const op = (name, ...payload) => clt._PCT__$o__$o_(Op, tags[name], ...payload);
const get = (value, key) => clt.option_$o_unwrap(clt.get(value, tags[key]));
const apply = (value, name, payload, id = 'code-a', time = 100) => updater(value, op(name, payload), id, time);

test('new codes preserve the original map storage shape and selection', () => {
  const next = apply(store, 'add-code', '1234567890');
  const code = clt.option_$o_unwrap(clt.get(read_codes(next), 'code-a'));
  assert.equal(get(next, 'pointer'), 'code-a');
  assert.equal(get(code, 'id'), 'code-a');
  assert.equal(get(code, 'code'), '1234567890');
  assert.equal(get(code, 'time'), 100);
  assert.equal(get(code, 'barcode?'), false);
});

test('Enum dispatch updates notes, barcode format, toggles and ordering time', () => {
  let next = apply(store, 'add-code', '1234567890');
  next = updater(next, op('note-code', 'code-a', clt._PCT__$o__$o_(clt.Option, clt.to_tag('some'), 'saved-note')), 'note', 100);
  next = updater(next, op('code-format', 'code-a', clt._PCT__$o__$o_(BarcodeFormat, tags['gs1-128'])), 'format', 100);
  next = apply(next, 'toggle-barcode', 'code-a');
  next = apply(next, 'touch-code', 'code-a', 'event-b', 200);
  const code = clt.option_$o_unwrap(clt.get(read_codes(next), 'code-a'));
  assert.equal(get(code, 'note'), 'saved-note');
  assert.equal(get(code, 'barcode-format'), tags['gs1-128']);
  assert.equal(get(code, 'barcode?'), true);
  assert.equal(get(code, 'time'), 200);
  next = apply(next, 'toggle-barcode', 'code-a');
  assert.equal(get(clt.option_$o_unwrap(clt.get(read_codes(next), 'code-a')), 'barcode?'), false);
});

test('deleting the last code restores empty selection without Option payload leaks', () => {
  const next = apply(apply(store, 'add-code', '1234567890'), 'remove-code', 'code-a');
  assert.equal(get(next, 'pointer'), null);
  assert.equal(clt.count(read_codes(next)), 0);
});

test('existing map-shaped saved data survives a Cirru EDN round trip', () => {
  const next = apply(store, 'add-code', 'legacy-code');
  const restored = clt.parse_cirru_edn(clt.format_cirru_edn(next));
  assert.equal(get(restored, 'pointer'), 'code-a');
  assert.equal(get(clt.option_$o_unwrap(clt.get(read_codes(restored), 'code-a')), 'code'), 'legacy-code');
});

test('typed Reel rendering supports both empty and selected shelves', async () => {
  assert.match(with_memo_frame(() => make_string(comp_container(new_reel(store), () => {}))), /No selection/);
  const next = apply(store, 'add-code', '1234567890');
  const html = with_memo_frame(() => make_string(comp_container(new_reel(next), () => {})));
  assert.match(html, /1234567890/);
  assert.match(html, /<img\b/);
  assert.doesNotMatch(html, /No icon:/);
  // The dedicated application callback must apply controls without recording a business op.
  const main = await import('../js-out/app.main.mjs');
  const field = (value, name) => clt.option_$o_unwrap(clt.get(value, clt.to_tag(name)));
  const before = clt.deref(main._$s_reel);
  const toggle = clt._PCT__$o__$o_(Control, clt.to_tag('toggle'));
  main.on_control_$x_(toggle);
  const after = clt.deref(main._$s_reel);
  assert.equal(field(after, 'display?'), !field(before, 'display?'));
  assert.equal(clt.count(field(after, 'records')), clt.count(field(before, 'records')));
  assert.ok(clt._$e_(field(after, 'store'), field(before, 'store')));
  main.on_control_$x_(toggle);
});

test('clearing a note keeps the saved :note nil shape', () => {
  let next = apply(store, 'add-code', '1234567890');
  next = updater(next, op('note-code', 'code-a', clt._PCT__$o__$o_(clt.Option, clt.to_tag('some'), 'saved-note')), 'note', 100);
  next = updater(next, op('note-code', 'code-a', clt._PCT__$o__$o_(clt.Option, clt.to_tag('none'))), 'note', 100);
  const code = clt.option_$o_unwrap(clt.get(read_codes(next), 'code-a'));
  assert.equal(get(code, 'note'), null);
  const restored = clt.parse_cirru_edn(clt.format_cirru_edn(next));
  assert.equal(get(clt.option_$o_unwrap(clt.get(read_codes(restored), 'code-a')), 'note'), null);
});


test('legacy plugin state keeps nil, replacement semantics and EDN replay', () => {
  const cursor = clt.parse_cirru_edn('[] :create');
  const payload = clt.parse_cirru_edn('{} (:show? true) (:legacy nil) (:nested $ {} (:saved nil))');
  const stale = clt.parse_cirru_edn('{} (:newer |discarded)');
  const initial = clt.assoc_in(store, clt.parse_cirru_edn('[] :states :create :data'), stale);
  const operation = plugin_state_op(cursor, payload);
  const decoded = clt.parse_cirru_edn(clt.format_cirru_edn(operation));
  assert.ok(clt._$e_(operation, decoded), 'plugin operation must survive EDN roundtrip');
  const updated = updater(initial, decoded, 'plugin', 100);
  const read = (v, key) => clt.option_$o_unwrap(clt.get(v, clt.to_tag(key)));
  const state = read(read(read(updated, 'states'), 'create'), 'data');
  assert.ok(clt._$e_(state, payload), 'update must replace the previous state');
  assert.equal(clt.to_js_data(state).legacy, null);
  assert.equal(clt.to_js_data(state).nested.saved, null);
  const cleared = updater(updated, plugin_state_op(cursor, clt._$n__$M_()), 'clear', 101);
  assert.deepEqual(clt.to_js_data(read(read(read(cleared, 'states'), 'create'), 'data')), {});
});

test('legacy field truthiness keeps falsey values distinct from zero and empty text', () => {
  for (const value of [null, undefined, false]) assert.equal(legacy_truthy_$q_(value), false);
  for (const value of [true, 0, '']) assert.equal(legacy_truthy_$q_(value), true);
});

test('typed plugins create, annotate, select barcode format and remove a code', () => {
  let current = store;
  const operations = [];
  const dispatch = (operation) => {
    operations.push(operation);
    current = updater(current, operation, 'synthetic', 100);
  };
  const render = () => with_memo_frame(() => comp_container(new_reel(current), () => {}));
  const elements = (root) => {
    const found = [], seen = new WeakSet();
    const visit = (node) => {
      if (!node || typeof node !== 'object' || seen.has(node)) return;
      seen.add(node);
      if (node.name?.value === 'Element') found.push(node);
      for (const key of ['values', 'extra', 'value', 'chunk']) if (Array.isArray(node[key])) node[key].forEach(visit);
      if (Array.isArray(node)) node.forEach(visit);
    };
    visit(root);
    return found;
  };
  const handler = (element, name) => {
    const fields = element.fields.map((field) => field.value);
    const events = element.values[fields.indexOf('event')];
    const index = events?.chunk?.findIndex((key) => key?.value === name) ?? -1;
    return index < 0 ? null : events.chunk[index + 1];
  };
  const click = (text) => {
    const element = elements(render()).findLast((node) => handler(node, 'click') && make_string(node).includes(text));
    assert.ok(element, `missing action ${text}`);
    handler(element, 'click')({}, dispatch);
  };
  const submit = (value) => {
    const input = elements(render()).find((node) => handler(node, 'input'));
    assert.ok(input, 'prompt input is visible');
    handler(input, 'input')(clt._$n__$M_(clt.newTag('type'), clt.newTag('input'), clt.newTag('value'), value), dispatch);
    const button = elements(render()).find((node) => node.values[node.fields.findIndex((field) => field.value === 'name')]?.value === 'button' && handler(node, 'click'));
    assert.ok(button, 'prompt submit is visible');
    handler(button, 'click')({}, dispatch);
  };
  click('feather-plus-square');
  submit('1234567890');
  click('feather-edit');
  submit('synthetic-note');
  click('feather-toggle-right');
  dispatch(clt._PCT__$o__$o_(Op, clt.newTag('states'), clt.parse_cirru_edn('[] :barcode :codes'), clt.parse_cirru_edn('{} (:show? true)')));
  click('GS1-128');
  click('feather-x-circle');
  const confirm = elements(render()).find((node) => node.values[node.fields.findIndex((field) => field.value === 'name')]?.value === 'button' && handler(node, 'click'));
  assert.ok(confirm, 'confirmation button is visible');
  handler(confirm, 'click')(clt.parse_cirru_edn('{} (:type :click)'), dispatch);
  for (const name of ['add-code', 'note-code', 'code-format', 'remove-code']) {
    assert.ok(operations.some((operation) => operation.tag.value === name), `${name} was dispatched`);
  }
  assert.equal(clt.count(read_codes(current)), 0);
});
