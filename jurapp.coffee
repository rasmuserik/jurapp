### Databases {{{1 ###

Questions = new Meteor.Collection "questions"
QuestionLists = new Meteor.Collection "questionlists"

### Load up data {{{2 ###

if Meteor.isServer then Meteor.startup -> if 0 == Questions.find().count()
  for name, obj of exampleData
    if obj.questions
      obj.name = name
      questions = []
      for question in obj.questions
        question.no = exampleData[question.no].decision
        questions.push Questions.insert question
      obj.questions = questions
      QuestionLists.insert obj if obj.desc

### Users {{{1 ###

users =
  "Sagsbehandler 1":
    kind: "sagsbehandler"
  "Sagsbehandler 2":
    kind: "sagsbehandler"
  "Sagsbehandler 3":
    kind: "sagsbehandler"
  "Områdeleder":
    kind: "manager"
  "Jura-admininstrator":
    kind: "jura"

users = for id, obj of users
  obj.id = id
  obj

### Site structure {{{1 ###
Router.map ->
  @route 'main', path: '/'
  @route 'workflow'
  @route 'edit'
  
Router.configure
  layout: 'layout'
  renderTemplates:
    'header': to: 'header'
    'footer': to: 'footer'
    'questions': to: 'questions'
  data: ->
    editable: -> Router.current().path is '/edit'
    questionList: -> QuestionLists.findOne {_id: Session.get "currentQuestion"}
    users: users
    questionLists: ->
      currentQuestion = Session.get "currentQuestion"
      for questionList in QuestionLists.find().fetch()
        questionList.selected = true if questionList._id == currentQuestion
        questionList

### Template logic {{{1 ###

### Main {{{2 ###
if Meteor.isClient
  Template.main.events
    "click .userlogin": ->
      Session.set "user", this

### Question Choice {{{2 ###
if Meteor.isClient
  Template.questionChoice.events
    "change .questionChoice": (a) ->
      questionId = $(a.target).val()
      if questionId == "newQuestion"
        questionId = QuestionLists.insert
          desc: "Tilføj titel"
          info: "Tilføj beskrivelse"
          questions: []
      Session.set "currentQuestion", questionId

### Questions {{{2 ###
if Meteor.isClient
  Template.questions.questions = ->
    QuestionLists.findOne({_id: Session.get "currentQuestion"})?.questions.map (id) -> Questions.findOne {_id: id}
  Template.questions.events
    "focusout .desc": (e) ->
      questionList = this.questionList()
      questionList.desc = e.target.innerHTML.trim()
      QuestionLists.update {_id: questionList._id}, questionList
    "focusout .info": (e) ->
      questionList = this.questionList()
      questionList.info = e.target.innerHTML.trim()
      QuestionLists.update {_id: questionList._id}, questionList
    "focusout .questionText": (e) ->
      this.text = e.target.innerHTML.trim()
      Questions.update {_id: this._id}, this
    "focusout .questionNo": (e) ->
      this.no = e.target.innerHTML.trim()
      Questions.update {_id: this._id}, this
    "click .addQuestion": (e) ->
      questionList = this.questionList()
      questionList.questions.push Questions.insert
        text: "...spørgsmål?"
        no: "...begrundelse hvis nej..."
      QuestionLists.update {_id: questionList._id}, questionList
