# Perspectives

Render views on the client OR on the server. Perspectives breaks traditional Rails views into
a logic-less Mustache template and a "Perspective", which allows you to render views either on
the client or on the server. Building up a thick client that shares the rendering stack
with the server allows sites to be SEO friendly and render HTML from deep links on the server
for a great client experience, while also incrementally rendering parts of the page if the
user already has the site loaded in a browser.

## Getting Started

In your Gemfile:

```ruby
gem 'perspectives'
```

Run the installer:

```sh
$ rails generate perspectives:install
```

Scaffold a resource if you want an example:

```sh
$ rails generate scaffold post title:string body:text
```

## Usage

### Vanilla perspectives

Perspectives live in `app/perspectives`. If you have a perspective called `app/perspectives/users/show.rb`,
then it will render the corresponding template from `app/mustaches/users/show.mustache`. For example, the following
perspective:

```ruby
# app/perspectives/users/show.rb
class Users::Show < Perspectives::Base
  output(:name) { 'Andrew' }
end
```

and template

```mustache
<!-- app/mustaches/users/show.mustache -->
Hello, {{name}}!
```

would render "`Hello, Andrew!`". To render it yourself, you could write:

```ruby
Users::Show.new.to_html
Users::Show.new.to_json
```

In order for a output to be available in the Mustache template, you have to explicitly mark it
as a output in a perspective. For example:

```ruby
class Users::Show < Perspectives::Base
  output(:name) { 'Andrew' } # declare a output

  def another_output
    'something else'
  end
  output :another_output # mark a method as a output
end
```

If you expect certain inputs, you define those are "inputs". For example:

```ruby
class Users::Show < Perspectives::Base
  input :user # expects to be passed a "user" object, available as "user"
  input :admin, allow_nil: true # can be optionally passed an "admin" input
end
```

All perspectives also get passed a "context" object when being created. For example, to
initialize the above object, we might write:

```ruby
user = User.find(params[:id])
context = {current_user: current_user}
Users::Show.new(context, user: user)
```

Which would make a `current_user` method available in the perspective. (any key in the context
hash automatically becomes a method on the perspective)

When you render a perspective in a controller, the easiest way is to write:

```ruby
class UsersController < ApplicationController
  perspectives_actions only: :show # sets up the responder

  def show
    user = User.find(param[:id])

    respond_with(perspective('users/show', user: user))
  end
end
```

The `respond_with` call is what figures out whether we want to return JSON or HTML to the client.

The default context is just an empty hash; if you want to change that, you can override the
`default_context` method in any controller, e.g.:

```ruby
class ApplicationController < ActionController::Base
  def default_context
    {current_user: current_user}
  end
end
```

### Nested Perspectives

If you want to render a perspective from another perspective, it's simple! For example:

```ruby
class Users::Show < Perspectives::Base
  input :user

  output(:name) { user.name }

  nested 'avatar', user: :user
  # will render Users::Avatar, passing "user" as an input, and make an "avatar"
  # method availabe in the mustache template
end
```

```mustache
<div class='user'>
  {{{avatar}}} <!-- use triple braces to print raw HTML -->
  <span>{{name}}</span>
</div>
```

What about rendering a collection? Also simple!

```ruby
class Projects::Show < Perspectives::Base
  output :project

  output(:title) { project.title }

  nested_collection 'tasks/show',
    collection: proc { project.tasks },
    output: :tasks

  # makes a "tasks" output available which is the list of tasks
end
```

```mustache
<h1>{{title}}</h1>
{{{tasks}}} <!-- renders all the tasks -->
```

### Macros

Perspectives also provides some nice macros to remove repeat code. For example,
`delegate_output` exposes a method from an object as a output:

```ruby
class Users::Show < Perspectives::Base
  input :user
  delegate_output :name, :email, to: :user
  # makes name, email outputs available
end
```

### Caching

Since Perspectives know about their dependent Perspectives via the `nested` and
`nested_collection` macros above, russian doll caching is trivial. To set that up,
just write:

```ruby
class Users::Show < Perspectives::Base
  cache { user } # uses "user" as the cache key
end
```

The Perspective cache will expire if the `user` changes, OR if the `users.mustache` template
changes, OR if the `Users::Show` perspective changes. (or if any `nested` Perspective changes)

### Client javascript

Perspectives has basically the same javascript API as [PJAX](https://github.com/defunkt/jquery-pjax),
and adds this line automatically to application.js if you use the `rails g perspectives:install`:

```javascript
$(function() { $(document).perspectives('a', 'body') })
```

That line says "intercept every click on 'a' tags", and request Perspectives JSON from
the server. Then render the resulting template, and replace the content of `$('body')` with the
result of rendering. If you want to use a different container, you could do something like:

```javascript
$(function() { $(document).perspectives('a', '#mycontainer') })
```

which would replace `$('#mycontainer')` instead of `$('body')`. If you did that, you would probably
also want a line like this in your `application_controller.rb`:

```ruby
layout lambda { |controller| !controller.request.xhr? && 'application' }
```

which will not render the layout at all if the request is made via xhr.

### Render into different containers

If you want to render a response into a container other than the default you set up, you can set
`'data-perspectives-target'` on an 'a' tag or a form. For example:

```html
<a href="/users/1" data-perspectives-target="#viewing-user">Andrew Warner</a>
```

Which will render the response into the `$('#viewing-user')` element. This might remind you of the PJAX
API.

You can also set `data-perspectives-target` on a form, which will render the response from the server
into the target element on `ajax:success`.

### Events

More events TK, but, when perspectives receives a JSON response from the server, it triggers an event
on the element (usually an anchor tag) which triggered the request, called "perspectives:response"

You can listen to this event and handle it as follows:

```javascript
$('a').on('perspectives:response', function(e, options) {
  // options has keys:
  //   json: (the json response)
  //   status: (response status)
  //   xhr: (the xhr),
  //   href: (requested href)
  //   container: (the rendering container)

  // the default behavior of this event is
  Perspectives.renderResponse(options)

  // but you can do whatever you want
  // (don't forget to stopPropagation if you don't want the
  //   default behavior to occur)
})
```

Perspectives also listens to the `'ajax:success'` event on forms, and renders the response from
the server.

### Assets version

Just like PJAX, Perspectives should re-render the entire page if the assets have changed in some
material way. If you just deployed your site, for example, we want to force everyone to reload the
entire page!

To configure asset checking, just add the following to your application layout:

```erb
<%= assets_meta_tag %>
```

If you're using Rails, Perspectives will set a response header which is the mtime of the most
recently updated asset file. Perspectives will do a full page reload if the assets have changed.

### More examples please!

For a full example app, check out [Rails Genius](https://github.com/RapGenius/railsgenius),
an app that I built to demonstrate Perspectives for Rails Conf. Rails Genius allows you to read
and write inline annotations on RailsConf talk abstracts.

(just like it's older sibling, [Rap Genius](http://rapgenius.com))

### Ruby version/framework support

Right now, the easiest way to use perspectives is with Rails 3.2+ / Rails 4, and Ruby 1.9.3+.

In theory, it should work with Rails 2, although that's not tested, and you have to do some more
work to set everything up. For setup stuff, check out `lib/perspectives/railtie.rb` to see what gets
set up in later version of Rails. The other big different is that, in Rails 2, you'll want to use
`respond_to` instead of `respond_with` (although that part should "just work")

## Philosophy

The core idea behind perspectives if that, if we use Mustache templates for templating, we can
render them either on the client or on the server. We can break the typical Rails ERB/HAML views
into one template, written in Mustache, which doesn't allow arbitrary code, and a "perspective" object,
written in Ruby, which holds the logic needed to generate a hash which can be used to render a Mustache
template.

Since the Mustache template never communicates directly with the perspective, when a client makes a
request to our site, we can build the hash of outputs with a perspective, and then either render it
on the server in the case that the client is a web crawler or a user visiting the page for the first time,
OR, in the case that the client already has a browser instance loaded up, we can simply return the JSON
hash to the client and let them render or update the page however they want.

If the user already has a page on the site loaded, then serving the JSON necessary to render a template
is much better than rendering it on the server and sending back an HTML fragment. If the server sends back
HTML, and the client wants to do something besides immediately render, then it would have to inspect the HTML
fragment from the response and yank out the information it wants. HTML is too brittle to rely upon for those
purposes! Instead, forcing the separation between the data needed to render a template and the layout/markup
in the template itself means that we're automatically building a JSON API as we're building out our site.

## TODO

There are some key things that are needed in order to make this library TRULY shine. The main thing is an
easy-to-use javascript library on the client that can be used to create client-only behavior. (such as transitioning
between pages, client-only behavior, etc) The ideally integration would be with some kind of existing library
like backbone.js, ember.js, or angular.js. With a front end "shell" over the client-side rendering side of this, we
could easily add client-only features without duplicating views and other business logic in the browser.

## License

MIT
