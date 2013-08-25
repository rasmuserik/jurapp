### Databases {{{1 ###

Questions = new Meteor.Collection "questions"
QuestionLists = new Meteor.Collection "questionlists"
Workflows = new Meteor.Collection "workflows"
Answers = new Meteor.Collection "answers"

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
      qp.log "update", next
      QuestionLists.update {_id: questionList._id}, questionList

  for questionList in QuestionLists.find().fetch()
    if questionList.next
      next = QuestionLists.findOne {_id: questionList.next}
      next.prev = questionList._id
      qp.log "update", next
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

users = for name, obj of users
  obj.name = obj._id = name
  obj

### Utility {{{1 ###

getCurrentQuestionList = ->
  (Session.get "currentQuestionList") || QuestionLists.findOne({prev: undefined})?._id
getQuestionList = -> QuestionLists.findOne({_id: getCurrentQuestionList()})

### Template logic {{{1 ###

### Workflows {{{2 ###
if Meteor.isClient
  Template.workflows.workflows = ->
    Workflows.find({ owner: (Session.get "user")._id}).fetch()
  Template.workflows.events
    "tap, click .workflow": ->
      Session.set "workflow", this
      Session.set "questionlist", this.questionlist

    "tap, click .newWorkflow": ->
      name = prompt "Navn for det nye workflow"
      return if !name
      obj =
        name: name
        owner: (Session.get "user")._id
        answers: {}
        open: true
      console.log "insert", obj
      Workflows.insert obj

### Workflow {{{2 ###
updateWorkflow = (fn) ->
  workflow = Session.get "workflow"
  fn workflow
  Workflows.update {_id: workflow._id}, workflow
  Session.set "workflow", workflow

setAnswer = (question, response) ->
  obj =
      workflow: (Session.get "workflow")._id
      question: question
  currentAnswer = Answers.findOne(obj) ||
    Answers.findOne {_id: Answers.insert obj}
  currentAnswer.response = response
  currentAnswer.user = Session.get("user")._id
  currentAnswer.timestamp = Date.now()
  Answers.update {_id: currentAnswer._id}, currentAnswer
  console.log currentAnswer

if Meteor.isClient
  Template.workflow.questionList = ->
    Session.set "currentQuestionList", (Session.get "workflow").questionList
    getQuestionList()
  Template.workflow.workflowName = -> (Session.get "workflow").name
  Template.workflow.questions = ->
    questions = getQuestionList()?.questions.map (id) -> Questions.findOne {_id: id}
    if questions then for question in questions
      answer =
        workflow: (Session.get "workflow")._id
        question: question._id
      console.log "ans", answer
      answer = Answers.findOne answer
      console.log "ans", answer
      if answer?.response
        question.response = {}
        question.response[answer?.response] = true
    #questionsx = getQuestionList()?.questions.map (id) ->
    #  question = Questions.findOne {_id: id}
    #  console.log question, id
    #  question
    questions
  Template.workflow.events
    "focusout .workflowId": (e) ->
      updateWorkflow (workflow) ->
        workflow.name = e.target.innerHTML.trim()
    "mouseup .answerYes": ->
      setAnswer this._id, "yes"
    "mouseup .answerNo": ->
      setAnswer this._id, "no"
    "mouseup .next": ->
      updateWorkflow (workflow) ->
        workflow.questionList = getQuestionList().next
    "mouseup .showWorkflows": -> Session.set "workflow", undefined
    "mouseup .prev": ->
      updateWorkflow (workflow) ->
        workflow.questionList = getQuestionList().next

### Main {{{2 ###
if Meteor.isClient
  Template.main.questionList = -> Session.get "currentQuestionList"
  Template.main.users = users
  Template.main.user = -> Session.get "user"
  Template.main.workflow = -> Session.get "workflow"
  Template.main.events
    "click .userlogin": ->
      Session.set "user", this
    "click .userlogout": ->
      Session.set "currentQuestionList", undefined
      Session.set "workflow", undefined
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

    "blur .questionStep": (e) ->
      questionList = this
      console.log this
      questionList.step = e.target.innerHTML.trim()
      QuestionLists.update {_id: questionList._id}, questionList

    "mouseup .newQuestionList": ->
      last = QuestionLists.findOne {next: undefined}
      console.log last
      last.next = QuestionLists.insert
        desc: "Indsæt beskrivelse her"
        info: "Indsæt yderligere information her"
        questions: []
        prev: last._id
      QuestionLists.update {_id: last._id}, last

    "mouseup .openQuestionList": -> Session.set "currentQuestionList", this._id

    "mouseup .swap": ->
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

    "mouseup .datadump": ->
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
