[InvTarget::] Final Inventory.

To print a summary of the contents of a repository.

@ This target is fairly simple: when we get the message to begin generation,
we simply ask the Inter module to output some text, and return true to
tell the generator that nothing more need be done.

=
void InvTarget::create_generator(void) {
	code_generator *inv_cgt = Generators::new(I"inventory");
	METHOD_ADD(inv_cgt, BEGIN_GENERATION_MTID, InvTarget::inv);
}

int InvTarget::inv(code_generator *gtr, code_generation *gen) {
	if (gen->to_stream)
		InterTree::traverse(gen->from, InvTarget::visitor,
			gen->to_stream, gen->just_this_package, PACKAGE_IST);
	return TRUE;
}

void InvTarget::inv_to(OUTPUT_STREAM, inter_tree *I) {
	InterTree::traverse(I, InvTarget::visitor, OUT, NULL, PACKAGE_IST);
}

void InvTarget::visitor(inter_tree *I, inter_tree_node *P, void *state) {
	text_stream *OUT = (text_stream *) state;
	inter_package *from = PackageInstruction::at_this_head(P);
	inter_symbol *ptype = InterPackage::type(from);
	if (Str::eq(InterSymbol::identifier(ptype), I"_module")) {
		@<Produce a heading for a module package@>;
	} else if (Str::eq(InterSymbol::identifier(ptype), I"_submodule")) {
		int contents = 0;
		LOOP_THROUGH_INTER_CHILDREN(C, P) contents++;
		if (contents > 0) {
			INDENT;
			@<Produce a subheading for a submodule package@>;
			INDENT;
			InterPackage::unmark_all();
			LOOP_THROUGH_INTER_CHILDREN(C, P)
				if (Inode::is(C, PACKAGE_IST))
					@<Inventory this subpackage of a submodule@>;
			InterPackage::unmark_all();
			OUTDENT;
			OUTDENT;
		}
	}
}

@<Produce a heading for a module package@> =
	WRITE("Module '%S'\n", InterPackage::name(from));
	text_stream *title = Metadata::optional_textual(from, I"^title");
	if (title) WRITE("From extension '%S by %S' version %S\n", title,
		Metadata::required_textual(from, I"^author"),
		Metadata::required_textual(from, I"^version"));

@<Produce a subheading for a submodule package@> =
	WRITE("%S:\n", InterPackage::name(from));

@<Inventory this subpackage of a submodule@> =
	inter_package *R = PackageInstruction::at_this_head(C);
	if (InterPackage::get_flag(R, MARK_PACKAGE_FLAG)) continue;
	inter_symbol *ptype = InterPackage::type(R);
	OUTDENT;
	WRITE("  %S ", InterSymbol::identifier(ptype));
	int N = 0;
	LOOP_THROUGH_INTER_CHILDREN(D, P) {
		if (Inode::is(D, PACKAGE_IST)) {
			inter_package *R2 = PackageInstruction::at_this_head(D);
			if (InterPackage::type(R2) == ptype) N++;
		}
	}
	WRITE("x %d: ", N);
	INDENT;
	int pos = Str::len(InterSymbol::identifier(ptype)) + 7;
	int first = TRUE;
	LOOP_THROUGH_INTER_CHILDREN(D, P) {
		if (Inode::is(D, PACKAGE_IST)) {
			inter_package *R2 = PackageInstruction::at_this_head(D);
			if (InterPackage::type(R2) == ptype) {
				text_stream *name = Metadata::optional_textual(R2, I"^name");
				if (name == NULL) name = InterPackage::name(R2);
				if ((pos > 0) && (first == FALSE)) WRITE(", ");
				pos += Str::len(name) + 2;
				if (pos > 80) { WRITE("\n"); pos = Str::len(name) + 2; }
				WRITE("%S", name);
				InterPackage::set_flag(R2, MARK_PACKAGE_FLAG);
				first = FALSE;
			}
		}
	}
	if (pos > 0) WRITE("\n");
