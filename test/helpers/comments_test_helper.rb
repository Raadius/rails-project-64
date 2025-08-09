# frozen_string_literal: true

module CommentsTestHelper
  # Recursively extracts all comments from a comment subtree structure
  # Used in tests to flatten nested comment hierarchies for assertions
  #
  # @param subtree [Hash] A hash structure where keys are PostComment objects
  #   and values are hashes of child comments
  # @return [Array<PostComment>] Flat array of all comments in the subtree
  def extract_all_comments_from_subtree(subtree)
    comments = []
    subtree.each do |comment, children|
      comments << comment
      comments.concat(extract_all_comments_from_subtree(children)) if children.is_a?(Hash)
    end
    comments
  end
end
