# Databases {{{1

Questions = new Meteor.Collection "questions"

# Load up data {{{2

if Meteor.isServer then Meteor.startup -> if 0 == Questions.find().count()
  for name, obj of exampleData
    if obj.questions
      obj.name = name
      for question in obj.questions
        question.no = exampleData[question.no].decision
      Questions.insert obj if obj.desc
      console.log "inserting example data to database", obj

# Site structure {{{1
sitemap =
  main: {path: "/"}

Router.map -> @route path, data for path, data of sitemap
  
Router.configure
  layout: 'layout'
  renderTemplates:
    'menu': to: 'menu'
    'footer': to: 'footer'
  data: ->
    title: 'Hello World'
    questions: -> Questions.find().fetch()
  run:
    console.log "run"
