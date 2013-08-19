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
    questionList: -> QuestionLists.findOne()
    questionLists: -> QuestionLists.find().fetch()

### Questions {{{1 ###
if Meteor.isClient
  Template.questions.questions = -> 
    QuestionLists.findOne()?.questions.map (id) -> Questions.findOne {_id: id}
  Template.questions.events
    "focusout .desc": (e) ->
      questionList = this.questionList()
      questionList.desc = e.target.innerText.trim()
      QuestionLists.update {_id: questionList._id}, questionList
    "focusout .info": (e) ->
      questionList = this.questionList()
      questionList.info = e.target.innerText.trim()
      QuestionLists.update {_id: questionList._id}, questionList
    "focusout .questionText": (e) ->
      this.text = e.target.innerText.trim()
      Questions.update {_id: this._id}, this
    "focusout .questionNo": (e) ->
      this.no = e.target.innerText.trim()
      Questions.update {_id: this._id}, this
