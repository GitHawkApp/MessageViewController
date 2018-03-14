has_lib_changes = !git.modified_files.grep(/MessageViewController/).empty?
no_changelog_entry = !git.modified_files.include?("CHANGELOG.md")

if has_lib_changes && no_changelog_entry
  warn("Any changes to library code should be reflected in the [Changelog](CHANGELOG.md). Please consider adding a note there.")
end
