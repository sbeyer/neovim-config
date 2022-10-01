return {
  opt = {
    -- status line everywhere
    -- laststatus = 2,

    -- completion behavior in command mode
    wildmode = 'longest:full,full',

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
