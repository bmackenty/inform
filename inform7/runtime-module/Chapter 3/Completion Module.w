[CompletionModule::] Completion Module.

The completion module contains material turning the collection of resources
into a playable work.

@ =
void CompletionModule::compile(void) {
	@<Version number constant@>;
	@<Semantic version number constant@>;
	@<Memory economy metadata@>;
}

@ So, for example, these might be |10.1.0| and |10.1.0-alpha.1+6R84| respectively.

@<Version number constant@> =
	TEMPORARY_TEXT(vn)
	WRITE_TO(vn, "[[Version Number]]");
	inter_name *iname = Hierarchy::find(I7_VERSION_NUMBER_HL);
	Emit::text_constant(iname, vn);
	Hierarchy::make_available(iname);
	DISCARD_TEXT(vn)

@<Semantic version number constant@> =
	TEMPORARY_TEXT(svn)
	WRITE_TO(svn, "[[Semantic Version Number]]");
	inter_name *iname = Hierarchy::find(I7_FULL_VERSION_NUMBER_HL);
	Emit::text_constant(iname, svn);
	Hierarchy::make_available(iname);
	DISCARD_TEXT(svn)

@<Memory economy metadata@> =	
	inter_name *iname = Hierarchy::find(MEMORY_ECONOMY_MD_HL);
	if (global_compilation_settings.memory_economy_in_force)
		Emit::numeric_constant(iname, 1);
	else
		Emit::numeric_constant(iname, 0);