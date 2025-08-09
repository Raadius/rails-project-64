PostLike.delete_all
PostComment.delete_all
Post.delete_all

default_categories = %w[general music movies lifestyle]

default_categories.each do |category_name|
  Category.find_or_create_by!(name: I18n.t("categories.#{category_name}"))
end

categories = Category.all.to_a
demo_user = User.first || User.create!(email: 'demo@example.com', password: 'password')

user = demo_user

posts = [
  { title: 'Rails 7 + Hotwire: the perfect match',
    body:  'In this comprehensive article, we explore the powerful combination of Rails 7 with Hotwire technologies including Turbo and Stimulus. These modern tools allow developers to create rich, interactive web applications without the complexity of traditional JavaScript frameworks like React or Vue. Hotwire brings the simplicity back to web development by leveraging server-side rendering while still providing dynamic user experiences through thoughtful JavaScript integration.',
    category: categories.sample },

  { title: 'Mastering PostgreSQL JSONB indexes for optimal performance',
    body:  'PostgreSQL JSONB data type gives you schemaless flexibility without sacrificing query performance when implemented correctly. This detailed guide covers advanced indexing strategies, GIN and GiST index types, and practical examples of how to optimize complex JSON queries. Learn how to balance flexibility with performance in modern web applications that require both structured and unstructured data storage patterns.',
    category: categories.sample }
].map do |attrs|
  Post.create!(attrs.merge(creator: demo_user))
end

PostLike.where.not(post_id: Post.select(:id)).delete_all
PostComment.where.not(post_id: Post.select(:id)).delete_all

posts.each_with_index do |post, idx|
  root1 = post.post_comments.create!(content: "Great read ##{idx + 1}!", user: demo_user)
  root2 = post.post_comments.create!(content: 'Could you benchmark against MySQL?', user: demo_user)

  child  = root1.children.create!(content: 'Seconded – numbers would be helpful.', user: demo_user, post: post)
  child.children.create!(content: 'Working on it, will update soon.', user: demo_user, post: post)
end
