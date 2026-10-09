# fifi terminology

- **Needle**: the regular expression used to search file contents and, with `NameMatch`, full paths.
- **SubNeedle**: a second content regular expression. Both patterns must match somewhere in a file
  for the content branch to accept it; they need not match the same line.
- **Haystack**: one filesystem search path. A trailing `%` requests recursion for that path.
- **File type**: a filename filter passed to `Get-ChildItem`, such as `*.ps1`, not a content format.
- **Name match**: an alternative match against the full file path. It can bypass content matching.
- **Quiet**: suppression of fifi's host status messages, while matching file objects remain output.

These terms describe `Find-InFiles.psm1`; no separate domain contexts or rejected synonyms are recorded.
