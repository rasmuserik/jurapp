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
  Template.main.questionList = -> Session.get "currentQuestionList"
  Template.main.users = users
  Template.main.user = -> Session.get "user"
  Template.main.events
    "click .userlogin": ->
      Session.set "user", this
    "click .userlogout": ->
      Session.set "user", undefined

### Question Lists {{{2 ###
if Meteor.isClient
  Template.questionLists.questionLists = ->
    result = []
    current = QuestionLists.findOne({prev: undefined})
    while current
      result.push current
      current = current.next && QuestionLists.findOne {_id: current.next}
    result
  Template.questionLists.events

    "click .newQuestionList": ->
      last = QuestionLists.findOne {next: undefined}
      console.log last
      last.next = QuestionLists.insert
        desc: "Indsæt beskrivelse her"
        info: "Indsæt yderligere information her"
        questions: []
        prev: last._id
      QuestionLists.update {_id: last._id}, last

    "click .openQuestionList": -> Session.set "currentQuestionList", this._id

    "click .swap": ->
      a = this.prev && QuestionLists.findOne {_id: this.prev}
      b = this
      c = this.next && QuestionLists.findOne {_id: this.next}
      return if not c
      d = c.next && QuestionLists.findOne {_id: c.next}
      a.next = c._id if a
      c.prev = a?._id
      c.next = b._id
      b.prev = c._id
      b.next = d?._id
      d.prev = b._id if d
      QuestionLists.update {_id: a._id}, a if a
      QuestionLists.update {_id: b._id}, b
      QuestionLists.update {_id: c._id}, c
      QuestionLists.update {_id: d._id}, d if d




    "click .datadump": ->
      window.open "data:application/json;charset=utf-8," + encodeURIComponent (JSON.stringify {
        questionlists: QuestionLists.find().fetch()
        questions: Questions.find().fetch()
      }, undefined, 2)
    
      



### Questions {{{2 ###
if Meteor.isClient
  Template.questions.editable = -> (Session.get "user").jura
  Template.questions.questionList = getQuestionList
  Template.questions.questions = ->
    getQuestionList()?.questions.map (id) -> Questions.findOne {_id: id}
  Template.questions.events
    "mouseup .next": -> Session.set "currentQuestionList", getQuestionList().next
    "mouseup .showQuestionLists": -> Session.set "currentQuestionList", undefined
    "mouseup .prev": -> Session.set "currentQuestionList", getQuestionList().prev
    "blur .desc": (e) ->
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
