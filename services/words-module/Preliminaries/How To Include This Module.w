How To Include This Module.

What to do to make use of the words module in a new command-line tool.

@h Status.
The words module provided as one of the "services" suite of modules, which means
that it was built with a view to potential incorporation in multiple tools.
It can be found, for example, in //inform7//, //inbuild// and //words-test//,
among others. //words-test// may be useful as a minimal example of a tool
using //words//.

By convention, the modules considered as "services" have no dependencies on
other modules except for //foundation// and other "services" modules.

A tool can import //words// only if it also imports //foundation//.

@h Importing the module.
We'll use the term "parent" to mean the tool which is importing //words//,
that is, which will include its code and be able to use it. As with any
imported module,
(*) The contents page of the parent's web must identify and locate the
module:
= (text as Inweb)
Import: somepath/words
=
(*) The parent must call |WordsModule::start()| just after it starts up, and
|WordsModule::end()| just before it shuts down. (But just after, and just
before, the corresponding calls to //foundation//.)

@h Using callbacks.
Shared modules like this one are tweaked in behaviour by defining "callback
functions". This means that the parent might provide a function of its own
which would answer a question put to it by the module, or take some action
on behalf of the module: it's a callback in the sense that the parent is
normally calling the module, but then the module calls the parent back to
ask for data or action.

The parent must indicate which function to use by defining a constant with
a specific name as being equal to that function's name. A fictional example
would be
= (text as Inweb)
	@d EXPRESS_SURPRISE_WORDS_CALLBACK Emotions::wow
	
	=
	void Emotions::wow(text_stream *OUT) {
	    WRITE("My word!\n");
	}
=
The words module has only a few callbacks, and they are all optional. The
following alphabetical list has references to fuller explanations:

(*) |MORE_PREFORM_OPTIMISER_WORDS_CALLBACK| and |PREFORM_OPTIMISER_WORDS_CALLBACK|
have the opportunity to flag certain Preform nonterminals in ways which will
help //The Optimiser//.

(*) |PREFORM_ERROR_WORDS_CALLBACK| allows the parent to issue errors about
Preform definitions in its own way; they will otherwise by default be standard
command-line error message written to |STDERR|.

(*) |PROBLEM_WORDS_CALLBACK| is called when a lexical error is found, and can
prevent this from being issued to the terminal as an error message: see
//Lexer::lexer_problem_handler//.

(*) |VOCABULARY_MEANING_INITIALISER_WORDS_CALLBACK| is called to attach a
meaning object to a single //vocabulary_entry//. In this module, meanings are
not our concern: all we provide is the opportunity for our parent tool to
attach such meanings to words. See //Vocabulary::vocab_entry_new//.

@ If the selection of a natural language is a meaningful thing to the parent,
it can define |NATURAL_LANGUAGE_WORDS_TYPE| to tell the Preform parser how
to refer to these. For example, the //supervisor// module has:
= (text as Inweb)
	@d NATURAL_LANGUAGE_WORDS_TYPE struct inform_language
=
