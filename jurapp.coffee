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

  for questionList in QuestionLists.find().fetch()
    if questionList.next
      next = QuestionLists.findOne {name: questionList.next}
      questionList.next = next?._id
      QuestionLists.update {_id: questionList._id}, questionList

  for questionList in QuestionLists.find().fetch()
    if questionList.next
      next = QuestionLists.findOne {_id: questionList.next}
      next.prev = questionList._id
      QuestionLists.update {_id: next._id}, next

### Users {{{1 ###

users =
  "Sagsbehandler 1":
    sagsbehandler: true
  "Sagsbehandler 2":
    sagsbehandler: true
  "Sagsbehandler 3":
    sagsbehandler: true
  "Områdeleder":
    manager: true
  "Jura-admininstrator":
    jura: true

users = for id, obj of users
  obj.id = id
  obj
### Utility {{{1 ###

getCurrentQuestionList = ->
  (Session.get "currentQuestionList") || QuestionLists.findOne({prev: undefined})?._id
getQuestionList = -> QuestionLists.findOne({_id: getCurrentQuestionList()})

### Template logic {{{1 ###

### Main {{{2 ###
if Meteor.isClient
  Template.main.users = users
  Template.main.user = -> Session.get "user"
  Template.main.events
    "click .userlogin": ->
      Session.set "user", this
    "click .userlogout": ->
      Session.set "user", undefined

### Questions {{{2 ###
if Meteor.isClient
  Template.questions.editable = -> (Session.get "user").jura
  Template.questions.questionList = getQuestionList
  Template.questions.questions = ->
    getQuestionList()?.questions.map (id) -> Questions.findOne {_id: id}
  Template.questions.events
    "click .next": -> Session.set "currentQuestionList", getQuestionList().next
    "click .prev": -> Session.set "currentQuestionList", getQuestionList().prev
    "focusout .desc": (e) ->
      questionList = getQuestionList()
      questionList.desc = e.target.innerHTML.trim()
      QuestionLists.update {_id: questionList._id}, questionList
    "focusout .info": (e) ->
      questionList = getQuestionList()
      questionList.info = e.target.innerHTML.trim()
      QuestionLists.update {_id: questionList._id}, questionList
    "focusout .questionText": (e) ->
      this.text = e.target.innerHTML.trim()
      Questions.update {_id: this._id}, this
    "focusout .questionNo": (e) ->
      this.no = e.target.innerHTML.trim()
      Questions.update {_id: this._id}, this
    "click .addQuestion": (e) ->
      questionList = getQuestionList()
      questionList.questions.push Questions.insert
        text: "...spørgsmål?"
        no: "...begrundelse hvis nej..."
      QuestionLists.update {_id: questionList._id}, questionList
