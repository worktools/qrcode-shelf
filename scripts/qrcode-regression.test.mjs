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
import { store, read_codes, Op, BarcodeFormat } from '../js-out/app.schema.mjs';
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
