class ChatbotMaker {
  constructor(options) {
    this.el = $(`#${options.elId}`)

    this.el.addClass('chatbot-maker')
    this.el.append(chatbotMakerUi.header)
    this.el.append(chatbotMakerUi.body)

    if (!options.data) {
      this.data = {
        "name": "",
        "avatar": false,
        "entrypoint": "1",
        "questions": []
      }
    } else {
      this.data = options.data
      loadChatbotMakerData(this)
    }

    attachChatbotMakerEvents(this)
  }
}

function loadChatbotMakerData(chatbot) {
  chatbot.el.find('.chatbot-title-input').val(chatbot.data.name)
  $questionsContainer = chatbot.el.find(".maker-body")

  chatbot.data.questions.forEach(question => {
    let questionId = question.id

    if (question.type == "question") {
      let $question = $(chatbotMakerUi.question)

      let $questionId = $question.find(".id span")
      $question.find(".question-title-input").val(question.text)
      $question.find(".question-title-label span").text(question.text)

      $question.find(".answer-type-select").val(question.answerType)

      if (question.is_optional) {
        $question.find(".required-question-select").val((question.is_optional).toString())
      }

      $questionId.text(questionId)

      $questionsContainer.append($question)
      $question.show("show");

      attachQuestionEvents($question, chatbot);

      let $answersContainer = $question.find(".answers");

      question.answers.forEach(answer => {
        let $answer = $(chatbotMakerUi.answer);

        $answer.find(".answer-id span").text(answer.id)
        $answer.find(".answer-text-input").val(answer.text)

        let $nqSelect = $answer.find(".answer-next-question-select");

        attachAnswerEvents($answer, chatbot);
        $nqSelect.val(answer.next);
        $answersContainer.append($answer);

        $answer.show();
      })
    } else if (question.type == "link") {
      let $question = $(chatbotMakerUi.link)

      let $questionId = $question.find(".id span")
      $question.find(".question-title-input").val(question.text)
      $question.find(".question-url-title-input").val(question.title)
      $question.find(".question-url-input").val(question.url)

      $question.find(".question-title-label span").text(question.text)
      $questionId.text(questionId)

      $questionsContainer.append($question)
      $question.show("show");

      attachLinkEvents($question, chatbot);
    }
  })

  if (chatbot.data.questions.length > 0) {
    chatbot.el.find(".new-link").removeClass("disabled")
  }
}

function attachChatbotMakerEvents(chatbot) {
  let $chatbotTitle = chatbot.el.find(".maker-header .chatbot-title-input")
  let $chatbotMakerHeader = chatbot.el.find(".maker-header")
  let $newQuestionBt = $chatbotMakerHeader.find(".new-question")
  let $newLinkBt = $chatbotMakerHeader.find(".new-link")

  $chatbotTitle.on("input", function () {
    chatbot.data["name"] = $(this).val()
  })

  $newQuestionBt.on("click", function () {
    $questionsContainer = chatbot.el.find(".maker-body")
    appendNewQuestion($questionsContainer, $(chatbotMakerUi.question), chatbot)
    chatbot.el.find(".maker-body-wrapper").animate({ scrollTop: chatbot.el.find('.maker-body').height() }, 300);
    $newLinkBt.removeClass("disabled")
  })

  $newLinkBt.on("click", function () {
    if (!$(this).hasClass("disabled")) {
      $questionsContainer = chatbot.el.find(".maker-body")
      appendNewLink($questionsContainer, $(chatbotMakerUi.link), chatbot)
      chatbot.el.find(".maker-body-wrapper").animate({ scrollTop: chatbot.el.find('.maker-body').height() }, 300);
    }
  })
}

function appendNewLink($questionsContainer, $question, chatbot) {
  let questionId = chatbot.data["questions"] == [] ? 1 : chatbot.data["questions"].length + 1;
  let $questionId = $question.find(".id span")

  $questionId.text(questionId)
  addAnswerNqOption(questionId, chatbot)
  $questionsContainer.append($question)
  $question.show("show");

  attachLinkEvents($question, chatbot);
  chatbot.data["questions"].push({
    "id": questionId,
    "type": "link",
    "title": "",
    "url": "",
    "answers": []
  });
}

function appendNewQuestion($questionsContainer, $question, chatbot) {
  let questionId = chatbot.data["questions"] == [] ? 1 : chatbot.data["questions"].length + 1;
  let $questionId = $question.find(".id span")

  $questionId.text(questionId)
  addAnswerNqOption(questionId, chatbot)
  $questionsContainer.append($question)
  $question.show("show");

  attachQuestionEvents($question, chatbot);
  chatbot.data["questions"].push({
    "id": questionId,
    "type": "question",
    "answerType": "button",
    "answers": [],
    "is_optional": false
  });
}

function addAnswerNqOption(id, chatbot) {
  let $nqSelect = chatbot.el.find(".answer-next-question-select");
  $nqSelect.each(function () {
    let $option = $(`<option value="${id}">(ID: ${id})</option>`);
    $(this).append($option)
  })
}

function attachQuestionEvents($question, chatbot) {
  const $hideQuestion = $question.find(".controls .hide-question");
  $hideQuestion.on("click", function() {
    $hideQuestion
    .toggleClass("closed-control");

    $question.find(".body")
    .slideToggle();
  })

  const $removeQuestion = $question.find(".controls .delete-question");
  $removeQuestion.on("click", function() {
    let questionId = $question.find(".id span").text();

    for (let i = 0; i < chatbot.data.questions.length; i++) {
      const question = chatbot.data.questions[i];

      if (question.id == questionId) {
        chatbot.data.questions.splice(i, 1)
      } else {
        if (question.answers) {
          question.answers.forEach(answer => {
            let oldId =  1 + Number(questionId)

            if (answer.next == questionId) {
              answer.next = "";
            } else if (answer.next == oldId) {
              answer.next = questionId;
            }
          })
        }
      }
    }

    $nextQuestion = $question.next();
    $question.remove();
    removeAnswersNq(questionId, chatbot)

    if (questionId != chatbot.data.questions.length + 1) {
      reassignQuestionsIds(questionId, $nextQuestion, chatbot)
      updateAllAnswersNq(questionId, chatbot)
    }

    let $chatbotMakerHeader = chatbot.el.find(".maker-header")
    let $newLinkBt = $chatbotMakerHeader.find(".new-link")

    if (chatbot.data.questions.length) {
      $newLinkBt.removeClass("disabled")
    } else {
      $newLinkBt.addClass("disabled")
    }
  })

  const $hideAnswers = $question.find(".controls .hide-answers");
  $hideAnswers.on("click", function() {
    $hideAnswers
    .toggleClass("closed-control");

    $question.find(".answers")
    .slideToggle();
  })

  const $addAnswer = $question.find(".controls .new-answer");
  $addAnswer.on("click", function() {
    addNewAnswer(this, chatbot)
  })

  const $answerTypeSelect = $question.find(".answer-type-select");
  $answerTypeSelect.on("change", function() {
    let answerType = $(this).val();
    let questionId = $(this).closest(".question").find(".id span").text()

    updateQuestionType(questionId, answerType, chatbot);
  })

  const $requireQuestionSelect = $question.find(".required-question-select");
  $requireQuestionSelect.on("change", function() {
    let is_required = $(this).val();
    let questionId = $(this).closest(".question").find(".id span").text()

    updateRequiredQuestion(questionId, is_required, chatbot);
  });

  const $titleInput = $question.find(".question-title-input");
  $titleInput.on("input", function() {
    let $label = $(this).closest(".question").find(".question-title-label span")
    let questionId = $(this).closest(".question").find(".id span").text()

    $label.text($(this).val())
    updateQuestionText(questionId, $(this).val(), chatbot)
    updateAnswersNqText(questionId, $(this).val(), chatbot)
  })
}

function attachLinkEvents($question, chatbot) {
  const $hideQuestion = $question.find(".controls .hide-question");
  $hideQuestion.on("click", function() {
    $hideQuestion
    .toggleClass("closed-control");

    $question.find(".body")
    .slideToggle();
  })

  const $removeQuestion = $question.find(".controls .delete-question");
  $removeQuestion.on("click", function() {
    let questionId = $question.find(".id span").text();

    for (let i = 0; i < chatbot.data.questions.length; i++) {
      const question = chatbot.data.questions[i];

      if (question.id == questionId) {
        chatbot.data.questions.splice(i, 1)
      } else {
        if (question.answers) {
          question.answers.forEach(answer => {
            let oldId =  1 + Number(questionId)

            if (answer.next == questionId) {
              answer.next = "";
            } else if (answer.next == oldId) {
              answer.next = questionId;
            }
          })
        }
      }
    }

    $nextQuestion = $question.next();
    $question.remove();
    removeAnswersNq(questionId, chatbot)

    if (questionId != chatbot.data.questions.length + 1) {
      reassignQuestionsIds(questionId, $nextQuestion, chatbot)
      updateAllAnswersNq(questionId, chatbot)
    }

    let $chatbotMakerHeader = chatbot.el.find(".maker-header")
    let $newLinkBt = $chatbotMakerHeader.find(".new-link")

    if (chatbot.data.questions.length) {
      $newLinkBt.removeClass("disabled")
    } else {
      $newLinkBt.addClass("disabled")
    }
  })

  const $titleInput = $question.find(".question-title-input");
  $titleInput.on("input", function() {
    let $label = $(this).closest(".question").find(".question-title-label span")
    let questionId = $(this).closest(".question").find(".id span").text()

    $label.text($(this).val())
    updateQuestionText(questionId, $(this).val(), chatbot)
    updateAnswersNqText(questionId, $(this).val(), chatbot)
  })

  const $urlTitle = $question.find(".question-url-title-input");
  $urlTitle.on("input", function() {
    let questionId = $(this).closest(".question").find(".id span").text()

    updateUrlTitle(questionId, $(this).val(), chatbot)
  })

  const $urlInput = $question.find(".question-url-input");
  $urlInput.on("input", function() {
    let questionId = $(this).closest(".question").find(".id span").text()

    updateQuestionUrl(questionId, $(this).val(), chatbot)
  })
}

function updateAllAnswersNq(id, chatbot) {
  chatbot.el.find(".answer-next-question-select").each(function() {
    let options = $(this).find("option");

    for (let i = id; i < options.length; i++) {
      let $option = $(options[i])
      $option.val(i)

      let optionText = $option.text().split(")")[1];
      $option.text(`(ID: ${i})${optionText}`);
    }
  })
}

function reassignQuestionsIds(id, $nextQuestion, chatbot) {
  for (let i = id - 1; i < chatbot.data.questions.length; i++) {
    const question = chatbot.data.questions[i];
    question.id--;
    question.answers.forEach(answer => {
      answer.id = `${question.id}.${answer.id.split(".")[1]}`
    })

    $nextQuestion.find(".id span").text(question.id)
    $nextQuestion.find(".answers .answer").each(function(index) {
      $(this).find(".answer-id span").text(`${question.id}.${index+1}`);
    })

    $nextQuestion = $nextQuestion.next();
  }
}

function removeAnswersNq(id, chatbot) {
  let $nqSelect = chatbot.el.find(".answer-next-question-select");
  $nqSelect.each(function() {
    $options = $(this).find("option")

    $options.each(function() {
      if ($(this).val() == id) {
        $(this).remove();
      }
    })
  })
}

function updateAnswersNqText(id, text, chatbot) {
  let $nqSelect = chatbot.el.find(".answer-next-question-select");
  $nqSelect.each(function() {
    $options = $(this).find("option")

    $options.each(function() {
      if ($(this).val() == id) {
        $(this).text(`(ID: ${id}) ${text ? text : ""}`);
      }
    })
  })
}

function updateQuestionText(id, text, chatbot) {
  for (let i = 0; i < chatbot.data.questions.length; i++) {
    const question = chatbot.data.questions[i];

    if (question.id == id) {
      chatbot.data.questions[i]["text"] = text
    }
  }
}

function updateUrlTitle(id, title, chatbot) {
  for (let i = 0; i < chatbot.data.questions.length; i++) {
    const question = chatbot.data.questions[i];

    if (question.id == id) {
      chatbot.data.questions[i]["title"] = title
    }
  }
}

function updateQuestionUrl(id, url, chatbot) {
  for (let i = 0; i < chatbot.data.questions.length; i++) {
    const question = chatbot.data.questions[i];

    if (question.id == id) {
      chatbot.data.questions[i]["url"] = url
    }
  }
}

function updateQuestionType(id, type, chatbot) {
  for (let i = 0; i < chatbot.data.questions.length; i++) {
    const question = chatbot.data.questions[i];

    if (question.id == id) {
      chatbot.data.questions[i]["answerType"] = type;
    }
  }
}

function updateRequiredQuestion(id, value, chatbot) {
  for (let i = 0; i < chatbot.data.questions.length; i++) {
    const question = chatbot.data.questions[i];

    if (question.id == id) {
      chatbot.data.questions[i]["is_optional"] = (value == 'true');
    }
  }
}

function updateSelectedAnswerNext(answerId, nextQuestionId, chatbot) {
  for (let i = 0; i < chatbot.data.questions.length; i++) {
    const question = chatbot.data.questions[i];

    if (question.id == answerId.split(".")[0]) {
      let answers = chatbot.data.questions[i].answers;

      answers.forEach(answer => {
        if (answer.id == answerId) {
          answer.next = nextQuestionId;
        }
      })
    }
  }
}

function updateSelectedAnswerText(answerId, answerText, chatbot) {
  for (let i = 0; i < chatbot.data.questions.length; i++) {
    const question = chatbot.data.questions[i];

    if (question.id == answerId.split(".")[0]) {
      let answers = chatbot.data.questions[i].answers;

      answers.forEach(answer => {
        if (answer.id == answerId) {
          answer.text = answerText;
        }
      })
    }
  }
}

function attachAnswerEvents($answer, chatbot) {
  $nextQuestionSelect = $answer.find(".answer-next-question-select");
  $answerTitle = $answer.find(".answer-text-input");
  $removeAnswer = $answer.find(".remove-answer");

  chatbot.data.questions.forEach(question => {
    $option = $(`<option value="${question.id}">(ID: ${question.id}) ${question.text? question.text : ""}</option>`);
    $nextQuestionSelect.append($option);
  })

  $answerTitle.on("input", function() {
    let $answer = $(this).closest(".answer");
    let answerId = $answer.find(".answer-id span").text();
    updateSelectedAnswerText(answerId, $(this).val(), chatbot)
  })

  $nextQuestionSelect.on("change", function() {
    let $answer = $(this).closest(".answer");
    let answerId = $answer.find(".answer-id span").text();
    updateSelectedAnswerNext(answerId, $(this).val(), chatbot)
  })

  $removeAnswer.on("click", function() {
    let $answer = $(this).closest(".answer");
    let $answers = $(this).closest(".answers");

    let answerId = $answer.find(".answer-id span").text();
    let questionId = answerId.split(".")[0]

    let answerIndex = Number(answerId.split(".")[1]) - 1
    let question = chatbot.data.questions[Number(questionId) - 1]

    if (answerIndex + 1 == question.answers.length) {
      question.answers.pop()
      $answer.remove()
    } else {
      question.answers.splice(answerIndex, 1)
      $nextAnswer = $answer.next()
      $answer.remove()

      for (let i = answerIndex; i < question.answers.length; i++) {
        const answer = question.answers[i];
        const splitId = answer.id.split(".")
        answer.id = `${splitId[0]}.${Number(splitId[1]) - 1}`
        $nextAnswer.find(".answer-id span").text(answer.id)

        $nextAnswer = $nextAnswer.next()
      }
    }
  })
}

function getQuestionAnswersLength(questionId, chatbot) {
  for (let i = 0; i < chatbot.data.questions.length; i++) {
    const question = chatbot.data.questions[i];

    if (question.id == questionId) {
      return chatbot.data.questions[i].answers.length
    }
  }
}

function appendTypedAnswer($question, $answer, chatbot) {
  let questionId = $question.find(".id span").text();

  $answerId = $answer.find(".answer-id span");
  let ansLen = getQuestionAnswersLength(questionId, chatbot);

  $answerId.text(`${questionId}.${ansLen + 1}`);

  attachAnswerEvents($answer, chatbot);

  $question.find(".answers").append($answer);

  for (let i = 0; i < chatbot.data.questions.length; i++) {
    const question = chatbot.data.questions[i];

    if (question.id == questionId) {
      chatbot.data.questions[i].answers.push({
        "id": `${questionId}.${ansLen + 1}`,
        "text": "",
        "next": ""
      })
    }
  }

  $answer.show("show");
}

function addNewAnswer(el, chatbot) {
  const $question = $(el).closest(".question");
  const answerType = $question.find(".answer-type-select").val();

  switch (answerType) {
    case "button":
    case "select":
    case "checkbox":
    case "fluid_list":
    case "text":
      appendTypedAnswer($question, $(chatbotMakerUi.answer), chatbot)
    break;

    default:
      break;
  }
}

module.exports = { ChatbotMaker, loadChatbotMakerData };
