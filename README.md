### tests and linter status:
[![Actions Status](https://github.com/Raadius/rails-project-64/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/Raadius/rails-project-64/actions)

Service available at this URL: https://hexlet-blog-project.onrender.com

### Common information

This project is a simple blog for sharing ideas and thoughts. It is written on Ruby on Rails with Slim templates. It supports authentication and authorization via Devise.

In this blog, you can create posts, comment on them, and like them to let other users know what you think about their posts!

### Preparation for project

Run the following commands:
```
make prepare-local
bin/rails s
```

That's it! You can now access the app at http://localhost:3000

### Tests
This project comes with a suite of tests. You can run them with the following command:
```
make run-tests
```

It will run all controllers, models, integration and views tests.

### Using the app

- Sign up: /signup
- Log in: /login
- Create a post: /posts/new
- View a post: /posts/:id
- Like a post: /posts/:id/like
- Comment on a post: /posts/:id/comments

### Working via Rails console (examples)

Start the console:
```
bin/rails c
```

- Create a user:
```
User.create!(email: 'user@example.com', password: 'password', password_confirmation: 'password')
```

- Create a category (name must be unique and 2..50 chars):
```
category = Category.create!(name: 'Tech')
```

- Create a post (title 5..255, body 200..4000 chars):
```
creator = User.first
Post.create!(title: 'My first post', body: 'A' * 200, category: category, creator: creator)
```

- Like a post:
```
post = Post.first
user = User.first
PostLike.create!(post: post, user: user)
# To unlike:
PostLike.find_by!(post: post, user: user).destroy!
```

- Add a comment:
```
post = Post.first
user = User.first
PostComment.create!(post: post, user: user, content: 'Nice post!')
```

- Add a nested (reply) comment:
```
parent = PostComment.first
PostComment.create!(post: parent.post, user: User.first, content: 'I agree', parent: parent)
```

Notes:
- Categories cannot be empty; name is required, unique, and length 2..50.
- A user can like a post only once.
- Post-title is required, and the length should be from 5 to 255 chars.
- Post-body is required, and the length should be from 200 to4000 chars.
- Comment-content is required, and the length should be from one to 1000 chars.
