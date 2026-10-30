# sbeyer's neovim configuration

## Preface

I have been using vim since basically forever but never got to clean up and modernize my
messy vim configuration. When I switched to neovim, I decided to configure it from
scratch. And I failed terribly, at least, at my perfectionism.

So I decided to depend on the work and perfectionism of others and use a pre-configured
neovim distribution. **Kudos goes to
[AstroNvim](https://github.com/AstroNvim/AstroNvim)**. My flavor is added with this
repository.

The active configuration uses **AstroNvim v6.1.1**, managed as a plugin by
[lazy.nvim](https://lazy.folke.io/). I have been using AstroNvim v3.45.3 for
a long time because I do not enjoy updating my neovim configuration; never touch a
running system! However, with more modern stuff coming to neovim and via plugins, there
is a need to update. So my new configuration is made with heavy use of LLMs because I
still do not enjoy configuring neovim or writing lua.

The unported parts of my former AstroNvim v3.45.3 configuration are kept in `old-v3/`
as a reference, e.g., to later port them if I still think it is useful. The contents
of this directory are not loaded.

## Installation

I did not write a fancy shell script, so you have to do all these steps manually. This
is actually good, so you can review them and ask yourself if it is right to do so.

### Step 1: requirements and recommended tools

See the [current AstroNvim requirements][astro] for details.

For the best experience, install `rg` (ripgrep) for live grep and a clipboard provider
such as `xclip` on X11 or `wl-copy`/`wl-paste` on Wayland.
Treesitter also needs the Tree-sitter CLI, which AstroNvim can install through Mason
if it is not installed on the system.

Use a terminal with true-color support, such as [Kitty][kitty]. Kitty includes a
built-in Nerd Font for symbols, so you do not need a patched text font there; see its
[font FAQ][kitty-fonts]. For other terminals, configure a current
[Nerd Font][nerd-fonts]. I am fond of [Hack Nerd Font v3.5.1][hack].
You might also want to check [getnf][getnf].

Mason installs tools in neovim's data directory, but some packages need additional
system runtimes or package managers: Node.js with `npm`, Python with `pip` and `venv`
support, or Rust with `cargo`. You can later run `:checkhealth mason` to check the
available tools.

### Step 2: get neovim

On Linux x86-64, the simplest way is to download an AppImage into a directory on
your `PATH`. AppImages require FUSE; see the [neovim installation guide][nvim] for
extraction instructions if FUSE is unavailable.


```sh
mkdir -p ~/.local/bin
curl -fL --output ~/.local/bin/nvim https://github.com/neovim/neovim/releases/download/v0.12.6/nvim-linux-x86_64.appimage
chmod +x ~/.local/bin/nvim
```

You can of course use another version of neovim, probably the latest one, but I
provide the version that I use and that I know my configuration works with.
My configuration prints a warning on startup if you are using another version
because not everything is guaranteed to work as expected.

Optionally, also use neovim when running `vim`, provided `~/.local/bin/vim` does not
already exist:

```sh
ln -s ~/.local/bin/nvim ~/.local/bin/vim
```

### Step 3: back up an existing configuration

The following paths assume Linux with the default XDG locations. Adjust them if you use
custom locations. Close neovim first and move any existing configuration out of the way:

```sh
backup_dir="nvim.bak-$(date +%Y%m%d-%H%M%S)"
test -d ~/.config/nvim && mv ~/.config/nvim ~/.config/$backup_dir
test -d ~/.local/share/nvim && mv ~/.local/share/nvim ~/.local/share/$backup_dir
test -d ~/.local/state/nvim && mv ~/.local/state/nvim ~/.local/state/$backup_dir
test -d ~/.cache/nvim && mv ~/.cache/nvim ~/.cache/$backup_dir
```

The data, state, and cache backups are optional but useful when switching from a
different configuration. These directories will be recreated; retain the backups if you
need their installed tools or other contents later.

### Step 4: clone this configuration

```sh
git clone https://github.com/sbeyer/neovim-config.git ~/.config/nvim
nvim
```

Allow the initial downloads and installations to finish.

## Features on top of AstroNvim

The main additions and customizations beyond AstroNvim's defaults are:

- **Clangd compilation database discovery.** Finds `compile_commands.json` in
  the project root and its `build*/` directories, deduplicating symlinks.
  Uses a single database automatically, asks when several exist, and remembers
  the choice per project for the session. Missing databases trigger a notification
  without disabling clangd's normal fallback (`lua/clangd/compile-commands.lua`).

- **Pinned clangd version.** `vim.g.clangd_version` in `init.lua` selects the
  clangd version installed by Mason. First use each session installs it if needed
  before starting clangd; installation failures warn and fall back to an available
  executable (`lua/clangd/version.lua`, `lua/plugins/mason.lua`).

- **Diff outlines.** Diff file headers appear as symbols with their `@@` hunks
  nested underneath, including patches without `index` metadata and files with
  only rename or binary changes. Available through the symbol picker and outline,
  with jump targets and breadcrumb ranges (Aerial, `lua/plugins/aerial.lua` and
  `queries/diff/aerial.scm`).

- **Git file removal.** `<Space>gD` offers deletion or untracking with buffer
  and Git change warnings, then searches for filename references. Deletion also
  closes the file's buffer (`lua/plugins/git.lua`, `lua/git/remove.lua`).

- **Custom statusline and window headers.** Compact three-letter mode labels
  and tab numbers replace the separate tabline. The active window shows symbol
  breadcrumbs when available; other windows show their file paths. Headers also
  show modified/read-only state and filetype labels where useful
  (`lua/plugins/heirline.lua`, `lua/plugins/astroui.lua`).

- **Dynamic, darker gutter.** Separate Git and diagnostic sign columns and a
  fold column appear only when needed, alongside relative line numbers.
  `<Space>u<` switches between dynamic and fixed column widths
  (`lua/plugins/heirline.lua`, `lua/plugins/astroui.lua`, `lua/plugins/astrocore.lua`).

- **Hybrid diagnostics.** Inline messages appear everywhere except the cursor
  line, where virtual lines show the diagnostics below the code instead.
  `<Space>uv` cycles through hybrid, virtual lines only, inline text only, and
  neither, without hiding signs or underlines. Refreshes after edits and buffer
  switches keep the cursor-line filtering correct (`lua/plugins/astrocore.lua`).

- **Consistent annotation backgrounds.** Inline diagnostics, diagnostic virtual
  lines, inlay hints, and CodeLens use matching subtle backgrounds while retaining
  their foreground colors and text styles. Backgrounds adapt to colorscheme changes
  (`lua/plugins/astroui.lua`).

- **Large-file folding protection.** Large buffers use manual folding rather
  than constructing expensive automatic fold trees, keeping generated files
  responsive when opening them or switching windows. Manual folds remain available
  (`lua/plugins/astrocore.lua`, `lua/plugins/astroui.lua`).

- **Flash navigation.** Label-based jumps and enhanced character finds are
  enabled through AstroCommunity (`lua/community.lua`).

- **Selective format-on-save.** Automatic formatting on save is enabled only
  for Rust; other filetypes can still be formatted manually when supported
  (`lua/plugins/astrolsp.lua`).

## Usage

This section mentions all the cool things that sooner or later should go into your
muscle memory.

The list is of course totally incomplete.

### Exiting neovim

Press Escape to return to Normal mode first. Commands beginning with `:` are
finished with Enter; `ZZ` and `ZQ` are Normal-mode key sequences without a colon.
`<Space>` means the Space key, my leader key. Uppercase and lowercase matter.

#### Close a window or exit the editor

`:q` (`:quit`) or `Ctrl-w q` closes the current window. It exits neovim only
when closing the last editing window across all tabs. Closing the last window
of one tab closes that tab, not the other tabs.

`<Space>q` runs `:confirm q`, offering a confirmation dialog when quitting would
otherwise abandon changes (AstroNvim). `<Space>Q` runs `:qa` (`:qall`) in my
configuration, attempting to exit all windows and tabs without forcing away
unsaved changes (`lua/plugins/astrocore.lua`).

`:close` or `Ctrl-w c` closes a window but refuses to close the last one.
`:tabclose` closes a tab but refuses to close the last tab. `<Space>c` closes
a buffer rather than quitting the editor (AstroNvim). AstroNvim can also
automatically close a tab or exit when only sidebar windows remain.

#### Save and quit

`:wq` writes the current file and closes its window. `:x` (`:xit`, `:exit`)
or `ZZ` does the same but writes only if the buffer changed, avoiding an
unnecessary write. These commands save the current buffer, not every open file;
other modified buffers can still prevent the final exit.

`:wqa` (`:wqall`) or `:xa` (`:xall`) writes all changed buffers and exits all
windows and tabs. If a changed buffer has no filename or cannot be written, neovim
stays open; some other buffers may already have been saved.

For an unnamed buffer, `:wq path/to/file` supplies a filename and closes that
window after saving. `:w` or `<Space>w` saves without quitting; `:wall` saves
all changed buffers without quitting (`<Space>w`: AstroNvim).

#### Quit without saving

`:q!` or `ZQ` force-closes the current window without writing its changes.
`Ctrl-q` is AstroNvim's Normal-mode shortcut for `:q!` in ordinary editing
windows; pickers can override it, for example to export quickfix entries.

This is not necessarily a full exit: other windows or tabs can remain, and
other modified hidden buffers can still keep neovim open. If the buffer is
also displayed elsewhere, closing one view does not discard that other view.

**`:qa!` (`:qall!`) exits all windows and tabs without saving any remaining
changes.** Use it only when discarding all unsaved work is intentional.

A `!` does not always mean discard: `:wq!` and `:wqa!` attempt forced writes
before quitting. They can override neovim's read-only protection, but cannot
guarantee success against filesystem permissions or a missing filename.

#### Prompts and hidden buffers

AstroNvim enables the `confirm` option, so ordinary quit commands can offer
Save/Discard/Cancel dialogs instead of only reporting an error. Cancel leaves
the editor open. `:confirm qa` explicitly requests confirmation for a full exit,
even if the option was disabled.

With neovim's default `hidden` option, closing a window with plain `:q` can leave
its modified buffer hidden in memory. A closed window is therefore not proof
that its file was saved or its edits discarded. Check `:ls` for buffers marked
`+`, and use `:wall` or `:wqa` when intending to save everything.

If neovim warns about more files in the argument list, `:next` visits the next
file. Use `:qa` when the intention really is to exit the entire editing session.

Running terminal jobs can also block a normal quit. Finish them first, or
confirm/force the exit knowing that neovim-owned terminal jobs may be terminated.
Session saving does not keep shell processes running and is not a substitute
for saving file edits.

#### External editors and special windows

`:cq` (`:cquit`) exits without saving and returns a nonzero status, by default 1.
This is useful for aborting an editor launched by `git commit` or another tool.
Unlike `:cq`, `:q!` normally returns success, so it is not a reliable way to tell
the calling program to cancel. Already-written changes are not undone by either.

In help, quickfix, and many other utility windows, plain `q` closes the window
(AstroNvim). In an ordinary editing buffer, `q` starts recording a macro instead;
it is not a quit shortcut.

In terminal input mode, use `Ctrl-\` followed by `Ctrl-n` before entering editor
commands. Typing `exit` ends the shell, while `F7` merely hides its terminal
(ToggleTerm); neither is a command to quit all of neovim.

In a Unix terminal, Normal-mode `Ctrl-z` suspends neovim rather than exiting.
Run `fg` in the shell to resume it.

### Motions

These keys work in Normal mode.

`h`, `j`, `k`, `l` move left, down, up, right. Without a count, `j` and `k`
follow screen lines when text wraps (AstroNvim).

`w` moves to the next word's beginning, `b` moves back to a word's beginning,
and `e` moves to a word's end. `W`, `B`, `E` treat everything between whitespace
as one word, ignoring punctuation.

Prefix a motion with a count: `5j` moves five actual lines down, `3w` moves three
words forward. Read the relative line numbers to choose the count instead of
counting lines yourself (relative numbers: `lua/plugins/astrocore.lua`).

`0` goes to the line's beginning, `^` to its first non-blank character, `$` to its
end. `gg` goes to the first line, `G` to the last, and `42G` to line 42.

`f` followed by a character finds it forward; `F` finds it backward. `t` and `T`
stop one character short of the target. `;` repeats the find, `,` reverses it.
Here these searches also cross line boundaries (Flash, enabled in `lua/community.lua`).

`s` starts a jump search: type part of the target text, then press its displayed
label to jump there (Flash, enabled in `lua/community.lua`).

`/text` searches forward, `?text` backward; press Enter to search.
`n` repeats the search, `N` reverses it. `*` and `#` search for the word under
the cursor, forward and backward.

`<Space>fl` opens a searchable list of lines in the current buffer; select a
match and press Enter to jump there (Snacks, AstroNvim default).

`%` jumps between matching brackets. `{` and `}` move backward and forward
by paragraphs. `Ctrl-d` and `Ctrl-u` scroll half a window down and up;
`zz` centers the current line on screen.

`Ctrl-o` returns to an older jump location; `Ctrl-i` moves forward again.
Use these to retrace searches and jumps, including jumps to other files.

`[d` and `]d` jump to the previous and next diagnostic. `[e` and `]e` visit
only errors; `[w` and `]w` visit only warnings (AstroNvim).

`[g` and `]g` jump to the previous and next Git change hunk (Gitsigns,
AstroNvim default).

`[y` and `]y` jump to the previous and next symbol; `<Space>ls` opens a symbol
picker (Aerial). For example, use it as a table of contents for this README:
filter or select a heading, then press Enter to jump to that section.

`gd` jumps to a definition, `gD` to a declaration, `gI` to an implementation,
and `gy` to a type definition, when supported by the language server (AstroLSP).
`<Space>lR` opens a references picker (Snacks, configured in `lua/plugins/astrolsp.lua`).

### Editing text

Combine an operator with a motion or text object: `d` deletes, `c` changes text
and enters Insert mode, and `y` copies. `d2w` deletes two words, `ciw` changes
a word, and `ci"` changes the contents of quotes. Text objects starting with `i`
select the inside; `a` includes the surrounding delimiters or whitespace.

`v` selects characters, `V` selects lines, and `Ctrl-v` selects a rectangular
block. Apply an operator to the selection. `>` and `<` indent or unindent;
Tab and Shift-Tab also indent and unindent Visual selections (AstroNvim).

`gv` reselects the last Visual area in the same selection mode. While selecting,
`o` moves the cursor to the other end so either end can be adjusted; `O` switches
corners horizontally in block mode. After leaving Visual mode, `` `< `` and
`` `> `` jump to the selection's start and end; `'<` and `'>` jump to their lines.

`dd` deletes a line, `yy` copies a line, and `p`/`P` put text after/before the
cursor or line. `.` repeats the last change; `u` undoes a change and `Ctrl-r`
redoes it.

Named registers use `a` through `z`. Lowercase replaces a register's contents;
uppercase appends to the same register, rather than naming a separate one.
`"ayy` copies a line into register `a`, `"Ayy` appends another line, and `"ap`
pastes it. `:registers` shows register contents.

Macros use these same registers and the same replace/append rule. `qq` starts
recording into register `q`; another `q` stops recording. `qQ` appends to that
macro instead of replacing it. `@q` replays it, `@@` repeats it, and `5@q` runs
it five times. Overwriting a register with copied text also overwrites its macro.

On a selection, `"+y` copies to the system clipboard; `"+p` pastes from it.
Clipboard access requires a working provider.

`gcc` comments out the current line, or removes its comment marker if already
commented. `gc` applies this toggle to a motion or Visual selection (neovim).
`<Space>/` runs `gcc` in Normal mode and `gc` on a Visual selection, so it toggles
comments on the current line or selected lines (AstroNvim).
In my configuration, Enter continues comments, but `o` and `O` do not
(`lua/plugins/astrocore.lua`).

For an unknown language, set the buffer's comment template before using these
commands: `:setlocal commentstring=#\ %s` uses `#` comments;
`:setlocal commentstring=//\ %s` uses `//`. The escaped space is part of the
template, and `%s` stands for the commented text.

For a permanent rule, add a `FileType` autocmd in `lua/plugins/astrocore.lua`
that sets `vim.bo[args.buf].commentstring = "# %s"` for the relevant filetype.
If the language has no recognized filetype yet, register its extension in
`opts.filetypes.extension` in the same file first. The separate `comments`
option controls comment continuation on new lines; `commentstring` controls
the commenting commands.

`:%s/old/new/gc` replaces matches throughout the buffer, asking for confirmation
at each match. The search part is a regular expression.

#### Undo history picker

`<Space>fu` opens the current buffer's undo history (Snacks, AstroNvim default).
Type to filter by changed text, and use `Ctrl-n`/`Ctrl-p` to browse entries.
The preview shows the change associated with each entry; browsing does not
change the buffer.

Enter restores the whole buffer to the state after the selected change,
not just the previewed lines. `Ctrl-c` cancels without restoring an older state.
The history includes branches created by editing after an undo, so it can recover
changes that are no longer on the current redo path.

To recover only some text, `Ctrl-y` copies the entry's added lines;
`Ctrl-Shift-y` copies its removed lines if the terminal supports that key chord.
Cancel the picker, then use `p` to paste the recovered text. These actions copy
text without rewinding the buffer (Snacks).

AstroNvim enables persistent undo, so saved undo history can survive restarts.

### Folding

`za` toggles the fold under the cursor; `zc` closes it and `zo` opens it.
`zM` closes all folds, while `zR` opens all folds. `zj` and `zk` jump to fold
boundaries below and above the cursor (neovim).

AstroNvim supplies automatic folds when supported. My large-file protection
switches large buffers to manual folding instead; select lines and press `zf`
to create a manual fold, or `zd` to delete one
(`lua/plugins/astroui.lua`, `lua/plugins/astrocore.lua`).

### Buffers, windows, and tabs

A buffer holds a file's contents. A window displays a buffer; a tab groups windows
into a layout. The same buffer can appear in several windows or tabs.

#### Buffers

`<Space>n` creates an empty buffer (AstroNvim). `:edit path/to/file` opens a file
in the current window.

`[b` and `]b` switch to the previous and next buffer in the current tab's buffer
list; counts work too, such as `3]b` (AstroNvim, `lua/plugins/astrocore.lua`).
`<Space>bp` returns to the previously used buffer (AstroNvim).

`<Space>fb` opens a searchable buffer picker: type to filter, then press Enter
to select a buffer (Snacks, AstroNvim default). Prefer this over `<Space>bb`,
AstroNvim's tabline-based picker, because my tabline is disabled
(`lua/plugins/heirline.lua`).

`<Space>c` closes the current buffer; `<Space>C` forces it closed, discarding
unsaved changes. `<Space>bc` closes the other buffers in the current tab's buffer
list; `<Space>bC` closes all buffers in that list (AstroNvim).

#### Windows

`|` splits the current window vertically, placing another view to the right;
`\` splits horizontally, placing it below (AstroNvim). Both initially show
the same buffer; use the buffer picker or `:edit` to show another file.

`Ctrl-h`, `Ctrl-j`, `Ctrl-k`, `Ctrl-l` focus the window to the left, below,
above, or right (Smart Splits, AstroNvim default).

`Ctrl-w H`, `Ctrl-w J`, `Ctrl-w K`, `Ctrl-w L` move the current window to the
far left, bottom, top, or right. Press `Ctrl-w`, then the uppercase letter.
`Ctrl-w x` exchanges it with the next window; `Ctrl-w r` rotates the windows.

`Ctrl` plus an arrow key resizes the window in that direction (Smart Splits,
AstroNvim default). `Ctrl-w =` equalizes window sizes.

`<Space>q` closes the current window, or exits neovim if it is the last one
(AstroNvim). Closing a window does not delete its buffer while neovim remains open.
`Ctrl-w o` closes the other windows in the current tab.

#### Tabs

`:tabnew` creates a tab with an empty buffer; `:tabedit path/to/file` opens a
file in a new tab. `:tab split` opens another view of the current buffer in a
new tab, leaving the original window in place.

`[t` and `]t` switch to the previous and next tab (AstroNvim). `2gt` jumps
directly to tab 2. Tab numbers appear in my statusline rather than a tabline
(`lua/plugins/heirline.lua`).

`Ctrl-w T` extracts the current window into a new tab. This requires at least
two windows in the source tab.

`:tabmove -1` and `:tabmove +1` move the current tab left and right.
`:tabclose` closes the current tab and its windows, not the buffers themselves.

### Terminals

`F7` opens or hides a terminal (ToggleTerm, AstroNvim default). Type ordinary
shell commands there. Hiding the terminal keeps its shell and running commands
alive; type `exit` to end the shell.

`<Space>tf`, `<Space>th`, and `<Space>tv` choose a floating terminal, a horizontal
split, or a vertical split. From Normal mode, `2` followed by `F7` opens or
toggles terminal 2, allowing separate shells for different tasks (ToggleTerm).

Terminal input mode sends keystrokes to the shell. Press `Ctrl-\` followed by
`Ctrl-n` to enter terminal Normal mode, where motions, selections, and copying
work as usual. Press `i` to resume shell input (neovim).

`F7` also hides the terminal directly from terminal input mode. In split
terminals, `Ctrl-h`/`Ctrl-j`/`Ctrl-k`/`Ctrl-l` move focus between windows
(AstroNvim). A plain Escape is not the standard way to leave terminal input mode.

### Sessions

Sessions restore open files, tabs, and window layouts across restarts
(Resession, AstroNvim default). Save edits before switching sessions;
do not rely on a session to preserve unsaved text.

`<Space>Ss` saves a named session; `<Space>Sf` selects a session to load.
`<Space>Sl` restores the last session, and `<Space>Sd` deletes a saved session.
Uppercase `S` distinguishes these bindings from other leader groups.

`<Space>SS` saves a session for the working directory; `<Space>S.` loads it,
and `<Space>SF` browses directory sessions. `<Space>St` saves the current tab
as a session (Resession).

On normal exit, AstroNvim automatically saves valid editing sessions as
the last session and as a working-directory session.

### Finding files

These pickers and their bindings come from AstroNvim's defaults (Snacks).
Type to filter results, use `Ctrl-n` and `Ctrl-p` to move through them,
and press Enter to open the selection.

`<Space>ff` finds files by name under the current working directory, respecting
ignore rules. `<Space>fF` includes hidden and ignored files too.

Inside the file finder, `Alt-h` toggles hidden files and `Alt-i` toggles files
excluded by `.gitignore` and other ignore rules. Press the same key again to
hide them. These toggles also work in the text-search picker.

`<Space>fs` combines open buffers, recent files, and files in the working directory
in one smart picker. `<Space>fb` searches only open buffers.

`<Space>fg` lists files tracked by Git. `<Space>fo` finds recently opened files
across projects; `<Space>fO` restricts that history to the working directory.

`<Space>fa` searches this neovim configuration's files, regardless of the current
working directory.

When you remember the contents rather than the filename, `<Space>fw` searches
text across files; `<Space>fW` includes hidden and ignored files. These content
searches require `rg` (ripgrep).

`<Space>fc` searches across files for the word under the cursor, without needing
to type it again. Unlike `*`, this is not limited to the current buffer.

Inside a file picker, `Ctrl-s` opens the selection in a horizontal split,
`Ctrl-v` in a vertical split, and `Ctrl-t` in a new tab.
`<Space>f<Enter>` resumes the previous picker with its search intact.

### Quickfix and picker selections

Quickfix is a list of file locations to work through, such as search matches
or compiler errors. `<Space>xq` opens it (AstroNvim); Enter jumps to an entry,
`[q` and `]q` visit the previous and next entry, and `:cclose` closes the list
(neovim). Closing the list window does not erase its contents.

In ordinary file or text-search pickers, Tab toggles a mark and moves down;
Shift-Tab toggles a mark and moves up. `Ctrl-a` selects all filtered results,
or clears the selection if all are already selected (Snacks).

`Ctrl-q` sends marked entries to quickfix and opens the list. With nothing
marked, it sends all current results. For example, search with `<Space>fw`,
mark the matches to inspect, press `Ctrl-q`, then work through them with
`]q` and `[q` (Snacks and neovim).

Some pickers override selection keys: Git status, for example, uses Tab for
staging rather than marking.

Location lists are similar but belong to a window rather than being global.
`<Space>xl` opens the current window's list (AstroNvim); `:lnext`/`:lprevious`
navigate it and `:lclose` closes it (neovim).

### Language tools (LSP)

Available features depend on the language server attached to the buffer.
Most bindings below are AstroNvim defaults (AstroLSP); my overrides live in
`lua/plugins/astrolsp.lua`. Press `<Space>l` and pause to see available language tools.

#### Completion and documentation

While typing, completion suggests symbols with their types and documentation.
`Ctrl-Space` opens completion manually. Use `Ctrl-n`/`Ctrl-p` to select suggestions
and `Ctrl-y` to accept: **n = no/next, p = previous, y = yes**.
`Ctrl-y` accepts the first suggestion if none is selected; Enter also accepts
a selected suggestion. `Ctrl-e` dismisses completion. `Tab`/`Shift-Tab` also
navigate suggestions or snippet fields (Blink, AstroNvim default).

`K` shows documentation for the symbol under the cursor. `gK` or `<Space>lh`
shows a function's signature and parameters; `<Space>u?` toggles automatic
signature help (neovim and AstroLSP).

#### Navigation and refactoring

The `gd`, `gD`, `gI`, and `gy` jumps described under Motions use the language
server's understanding of definitions, declarations, implementations, and types.
`<Space>lG` searches workspace symbols (AstroLSP).

`<Space>lR` opens a picker of references to the current symbol, rather than
searching for matching text (Snacks, `lua/plugins/astrolsp.lua`).
`[r` and `]r` jump between highlighted references in the current buffer;
`<Space>ur` toggles that highlighting (Snacks words, AstroNvim default).

`<Space>lr` renames a symbol and updates its uses through the language server.
`<Space>la` offers code actions, such as fixes or refactorings, and also works
on a Visual selection. `<Space>lA` requests file-level source actions, such as
organizing imports, when the server provides them (AstroLSP).

#### Diagnostics and annotations

`[d` and `]d` jump to the previous and next diagnostic; `[D` and `]D` jump
to the first and last diagnostic in the buffer (neovim).
`[e` and `]e` visit errors only; `[w` and `]w` visit warnings only (AstroNvim).

`<Space>ld` or `gl` shows diagnostics for the current line (AstroNvim).
`<Space>lD` opens a searchable picker of known diagnostics across buffers
(Snacks, AstroNvim default). My hybrid display and `<Space>uv` cycle are described
in the feature overview.

Inlay hints show information such as inferred types or parameter names beside
the code. `<Space>uh` toggles them for the current buffer; `<Space>uH` toggles
the global setting. They start disabled here (AstroLSP, `lua/plugins/astrolsp.lua`).

CodeLens displays server-provided inline actions, such as test runners or
reference counts. `<Space>lL` runs an action, `<Space>ll` refreshes CodeLens,
and `<Space>uL` toggles it. CodeLens starts enabled here, but requires server
support (AstroLSP, `lua/plugins/astrolsp.lua`).

Semantic highlighting colors symbols according to their meaning, beyond syntax
alone. It starts enabled; `<Space>uY` toggles it for the current buffer
(AstroLSP, `lua/plugins/astrolsp.lua`).

#### Formatting and server management

`<Space>lf` formats the buffer, or the selected range in Visual mode when
supported. `<Space>uf` toggles the buffer's format-on-save setting;
`<Space>uF` toggles the global setting. My format-on-save allowlist restricts
automatic formatting to Rust (`lua/plugins/astrolsp.lua`).

`<Space>li` runs the LSP health check to inspect attached servers and configuration
(AstroNvim). `:Mason` or `<Space>pm` manages installed language servers and tools
(Mason, AstroNvim default).

#### C/C++ source/header switching

With clangd attached, `<Space>lw` switches between a source file and its header.
This is clangd-specific, rather than a general LSP feature (clangd_extensions.nvim,
enabled by the C/C++ pack in `lua/community.lua`).

Outside clangd buffers, AstroNvim can instead use `<Space>lw` to request workspace
diagnostics, if the attached server supports that feature (AstroLSP).

### Git

Press `<Space>g` and pause to see available Git actions.
File-level bindings appear when Gitsigns attaches to a file; repository pickers
come from Snacks (AstroNvim defaults).

#### Reviewing and staging changes

The gutter marks changed lines, while the statusline shows the branch and change
counts (Gitsigns, `lua/plugins/heirline.lua`). `[g` and `]g` visit the previous
and next hunk; `[G` and `]G` jump to the first and last hunk (Gitsigns).

`<Space>gp` previews the current hunk inline. `<Space>gd` opens a side-by-side
diff for the current file. `vig` selects the current hunk using the `ig` text
object (Gitsigns).

`<Space>gs` stages or unstages the current hunk; in Visual mode it stages the
selected lines, allowing partial hunks. `<Space>gS` stages the whole buffer.
`:Gitsigns reset_buffer_index` unstages the file without discarding its changes
(Gitsigns).

`<Space>gr` resets the current hunk, or the selected lines in Visual mode,
discarding those edits. `:Gitsigns reset_buffer` resets all hunks in the buffer
(Gitsigns).

`<Space>gR` resets all hunks in the buffer (Gitsigns).

`<Space>gD` offers to delete the current file or untrack it while keeping it on
disk, showing any buffer or Git changes before removal. Afterwards, a filename
search helps find remaining references. Deletion also closes the file's buffer
and discards unsaved edits (`lua/plugins/git.lua`, `lua/git/remove.lua`).

#### History and blame

`<Space>gl` shows blame information for the current line; `<Space>gL` includes
the full commit details. `:Gitsigns toggle_current_line_blame` toggles a persistent
blame annotation on the cursor line (Gitsigns).

`<Space>gc` browses repository commits; `<Space>gC` shows the current file's history,
following renames. Use the preview to inspect commits. Confirming a commit requests
a checkout, which can put Git into detached HEAD state (Snacks).

#### Repository pickers

`<Space>gt` opens Git status with previews of changed files. Enter opens a file;
Tab stages or unstages the selected entries (Snacks).

`<Space>gb` opens the branch picker; confirming a branch checks it out.
`<Space>gT` opens the stash picker; confirming a stash applies it without dropping
it (Snacks).

`<Space>fg` finds tracked files, as described under Finding files (Snacks).

#### Remote browsing and LazyGit

`<Space>go` opens the current file on its remote hosting site in a browser,
including the selected line range in Visual mode. With the cursor on a valid
commit hash, it opens that commit instead (Snacks gitbrowse).

If `lazygit` is installed, `<Space>gg` or `<Space>tl` toggles its floating
terminal UI for staging, committing, managing branches and stashes, and pushing
or pulling. These bindings are only created when the executable is available
(ToggleTerm, AstroNvim default).

Commit messages, rebase instructions, and `.gitattributes` files also have
Treesitter syntax support (`lua/plugins/git.lua`).

### Debugging and building

AstroNvim already includes nvim-dap and nvim-dap-ui; they do not need to be added
separately. The C/C++ community pack also requests the `codelldb` adapter
and includes cmake-tools (`lua/community.lua`).

`F9` or `<Space>db` toggles a breakpoint. `F5` starts or continues a configured
debug session; `F10` steps over, `F11` steps into, and Shift-F11 steps out.
`<Space>du` toggles the debugger UI for inspecting variables, watches, and the
call stack; `<Space>dE` evaluates an expression or a Visual selection
(nvim-dap and nvim-dap-ui, AstroNvim defaults).

In a CMake project, `:CMakeGenerate` configures it, `:CMakeSelectBuildTarget`
chooses a build target, and `:CMakeBuild` builds it. `:CMakeSelectLaunchTarget`
chooses what `:CMakeRun` runs (cmake-tools, C/C++ community pack).

Included plugins do not guarantee a ready-to-run setup for every project:
C/C++ debugging still needs a compatible installed adapter, an executable with debug
symbols, and suitable launch settings; building needs the project's toolchain.

### UI tweaks

For pair programming or screen sharing, `:setlocal number norelativenumber`
shows absolute line numbers in the current window. `:setlocal number relativenumber`
restores my default. `<Space>un` cycles through numbering modes rather than
simply toggling relative numbers (AstroNvim). To change the startup default,
edit `relativenumber` in `lua/plugins/astrocore.lua`.

`<Space>uw` toggles line wrapping; `<Space>us` toggles spell checking, and
`<Space>uS` toggles concealment of text such as markup syntax (AstroNvim).
`<Space>u|` toggles indentation guides; `<Space>ft` opens the colorscheme picker
(Snacks, AstroNvim defaults).

My whitespace and wrapped-line markers make tabs, trailing spaces, and
continuation lines visible (`lua/plugins/astrocore.lua`).
`:setlocal nolist` hides whitespace markers; `:setlocal list` restores them.

`<Space>u<` toggles dynamic gutter widths; `<Space>uv` cycles diagnostic text
and virtual lines, as described in the feature overview
(`lua/plugins/astrocore.lua`, `lua/plugins/heirline.lua`).

### Maintenance and troubleshooting

`:Lazy` or `<Space>ps` shows installed plugins. `<Space>pu` checks for updates;
`<Space>pU` updates plugins. `lazy-lock.json` records plugin revisions
(lazy.nvim, AstroNvim defaults).

`:Mason` or `<Space>pm` manages language servers, formatters, and debug adapters
(Mason). `:TSUpdate` updates Treesitter parsers. `<Space>pa` runs AstroNvim's
combined plugin/parser update and updates Mason tools when supported.
Restart neovim after configuration or plugin changes.

`:MasonInstall clangd@21.1.8` installs a specific clangd version manually.
My automatic version selection is configured by `vim.g.clangd_version` in `init.lua`.

`:checkhealth` checks the overall environment; `:checkhealth mason` checks tool
installation prerequisites, and `<Space>li` checks the LSP setup.
`:messages` shows message history; `<Space>fn` opens notification history
(Snacks).

`:verbose nmap <Leader>gs` shows the active mapping and where it was defined;
`:verbose setlocal relativenumber?` helps trace an unexpected option value.
Check mappings in the affected buffer because buffer-local mappings can override
global ones.

`:AstroVersion` reports the AstroNvim version. `:version` reports the running
neovim version, and `:echo v:progpath` identifies its executable. My expected
neovim release is defined in `init.lua`; startup warns about incompatible versions.

[astro]: https://docs.astronvim.com/
[kitty]: https://sw.kovidgoyal.net/kitty/
[kitty-fonts]: https://sw.kovidgoyal.net/kitty/faq/#kitty-is-not-able-to-use-my-favorite-font
[nerd-fonts]: https://www.nerdfonts.com/font-downloads
[hack]: https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/Hack.zip
[getnf]: https://github.com/ronniedroid/getnf
[nvim]: https://github.com/neovim/neovim/blob/master/INSTALL.md
