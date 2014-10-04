" Operator to do two or more operators.
" Version: 0.1.0
" Author : thinca <thinca+vim@gmail.com>
" License: Creative Commons Attribution 2.1 Japan License
"          <http://creativecommons.org/licenses/by/2.1/jp/deed.en>

let s:save_cpo = &cpo
set cpo&vim

let s:operators = []

function! s:create_local_map()
  let map = 'onoremap <silent> <Plug>(operator-sequence-select-%s) ' .
  \                            ' :normal! %s`[o`]<CR>'
  for [type, key] in [
  \   ['char', 'v'],
  \   ['line', 'V'],
  \   ['block', '<C-v>'],
  \ ]
  execute printf(map, type, key)
  endfor
endfunction
call s:create_local_map()

function! operator#sequence#map(...)
  if mode(1) ==# 'no' && s:operators != a:000
    return ''
  endif
  set operatorfunc=operator#sequence#do
  let s:operators = copy(a:000)
  return 'g@'
endfunction

function! operator#sequence#do(type)
  let prefix = (v:count ? v:count : '')
  \          . (v:register != '' ? '"' . v:register : '')
  let motion = printf("\<Plug>(operator-sequence-select-%s)", a:type)
  let seq = ''
  for op in s:operators
    let seq .= type(op) == type([]) ? join(op, '') : prefix . op . motion
    unlet op
  endfor
  let save_selection = &selection
  set selection=inclusive
  try
    execute 'normal' seq
  finally
    let &selection = save_selection
  endtry
endfunction

let &cpo = s:save_cpo
