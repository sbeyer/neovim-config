return {
  opt = {
    -- keep statusline when in command mode
    cmdheight = 1,

    -- completion behavior in command mode
    wildmode = 'longest:full,full',

    -- never show tabline (we show tab information in statusline)
    showtabline = 0,

    -- disable weird completion behavior regarding suffixes
    suffixes = '',

    -- enable mouse only for Normal and Visual mode only
    mouse = 'nv',

    -- make whitespace visible
    list = true,
    listchars = 'tab:^`,trail:~,extends:\\,precedes:»',

    -- make implicit linebreaks visible
    wrap = true,
    showbreak = '  «',
    breakindent = true,
    breakindentopt = 'shift:2,sbr',
  }
}
