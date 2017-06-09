# Contents

The XSLT files in this repository convert Nathan Hill's Tibetan verb dictionary
to lexicon files that can be used for various corpus and computational purposes.

## Source Dictionary

- **dictionary.txt**: Original dictionary file passed on by Nathan Hill in 2010.
- **dictionary.xml**: Well-formed XML converted from the original file through
various steps, with copula verbs _lags_ and _mchis_ removed.

Note that the word "auxiliary" is misspelled as "auxillary" in its use as a tag
in these files. Our stylesheets use the misspelling rather than try to fix it.

These files are digital versions of the following published dictionary:

> Hill, Nathan W. (2010) _A Lexicon of Tibetan Verb Stems as Reported by the
> Grammatical Tradition._ Munich: Bayerische Akademie der Wissenschaften.
> (Studia Tibetica)

## Stylesheets

### Requirements

The XSLT 2.0 stylesheets in this repository were written for Saxon B, an
"older product". The current open-source Saxon release is Saxon HE. As noted
by Michael Kay,

> Saxon-HE does not offer all the capabilities that were present in Saxon-B.
> Most notably, support for Saxon extension functions and other extensions was dropped,
> as was the capability for writing extension functions that rely on dynamic loading of
> Java or .NET code (a new facility for "integrated extension functions" is however available).
> Users whose code relies on these features of Saxon-B should either purchase the Professional
> Edition product or stick with Saxon-B: the latest release of Saxon-B is 9.1.0.8, and although
> there are no plans to develop it further or maintain it, it will remain available indefinitely."

The stylesheets here use this deprecated method of calling extensions. In particular,
static functions from the jar file **DictionarySearchStandalone.jar** are used to convert text
from Extended Wylie to Unicode Tibetan. As a result, if you try to run these stylesheets
with Saxon HE, you'll get the following error message:

> Note that direct calls to Java methods are not available under Saxon-HE

Therefore if you want to reproduce the process described here, you would need to go to
http://saxon.sourceforge.net/ and then follow the links to download Saxon B. Find **saxon9.jar**
and make sure it is in the Java classpath when you invoke the XSLT transformer.

### Files

The original stylesheet **verbs.xsl** hails from 2012. When applied to **dictionary.xml**,
it creates a verb lexicon file (**verbs.txt**) in horizontal format, with the verb form
separated from the part-of-speech tag by the pipe character. Lemmas are ignored.

**verbs.xsl** was modified in 2017 as **verbs-with-lemmas.xsl** in order to include
lemmas. When applied to **dictionary.xml**, this new stylesheet creates a vertically formatted
lexicon file, with three tab-delimited columns: verb form, part-of-speech tag, and lemma.

**lemmas.xsl** is a variant of **verbs-with-lemmas.xsl** that generates a list of
lemmas only. I load the output, **lemmas.txt**, into LibreOffice to make sure that the
stylesheet doesn't generate any duplicate lemmas.

# Lemmatisation

## Basic Principles

The verb dictionary gives present, past, and future stem forms for most verbs,
excepting some auxiliaries. Imperative stem forms can be absent, especially from
involuntary verbs.

Each verb form (present stem, past stem, and so on) is lemmatized to its headword
and given the part-of-speech tag that corresponds to the form (*v.pres*, *v.fut*, 
and so on). Verbs which are not given with multiple stem forms - like auxiliaries -
are tagged *v.invar*.

If the same form is shared by multiple stems, then it is given all appropriate
mixed tags as well as any simple tags. For example, a form which is the same for
present, past, and future stems will acquire **all** of the following tags:

1. *v.pres*
2. *v.past*
3. *v.fut*
4. *v.fut.v.pres*
5. *v.fut.v.past*
6. *v.past.v.pres*
7. *v.invar*

On the other hand, a form which is only shared between present and future stems
will receive the following tags:

1. *v.pres*
2. *v.fut*
3. *v.fut.v.pres*

## Duplicate Headwords

Many verbs in the dictionary are given with multiple present stems, so it is
impractical to lemmatise to the present. It is much easier to lemmatise to the
headword, which less frequently has multiple forms. (When it does, we take the first
orthographic form.)

When a headword is unique in the dictionary, then the lemma is identical to the headword.
For example, there is only one headword བཀུར་ - its lemma is བཀུར་.

However, where the same headword corresponds to more than one dictionary entry, then we
create multiple numbered lemmas. For example, there are two headwords བཀོང་ - these are
lemmatised as བཀོང་√1 and བཀོང་√2. The most lemmas I have found for a single form is four,
as in this case:

- འཛེར་√1
- འཛེར་√2
- འཛེར་√3
- འཛེར་√4

The source dictionary file specially tags so-called auxiliaries. To preserve this
annotation, for possible use downstream, we create a separate lemma ending in √x for
any such verb.

The file **lemmas.txt** lists all the lemmas derived in this manner. Having imported this
file into LibreOffice, I can confirm that this list of nearly 1900 lemmas contains no
duplicates. Each lemma is uniquely named.

## Word-final Tshegs

For each form, we include variants with and without a word-final tsheg. Not all such
variants will be encountered in practice, including them makes us well-prepared in case
they are found.

## Verbal Nouns

Rules of Tibetan grammar dictate the use of པ་ or བ་ to form verbal nouns. Rather than
following these rules, we include for each form variants with both word endings. Most
such variants will not be encountered in practice, but by including them we are prepared
in case they do occur, in mistaken spellings or other unexpected situations.

## The List of Lemmas

**lemmas.txt** is a tab-delimited file that can be opened into a spreadsheet application
such as LibreOffice. In addition to a list of lemmas, it contains the following additional
information that has been extracted from **dictionary.xml**. (Note that transitivity and
causation information has not yet been incorporated into the list of lemmas.)

### Volitionality

Many verbs in the dictionary are classified for volitionality, based on the sources
consulted. This information is copied to the second column of **lemmas.txt**. Possible
values include:

1. `Voluntary`: The verb is volitional.
2. `Involuntary`: The verb is non-volitional.
3. `VoluntaryInvoluntary` or `InvoluntaryVoluntary`: The verb has been classified
as both volitional and non-volitional, either by the same author or by different
authors.

### Argument Frames 

The third column of **lemmas.txt** shows the argument frame for the verb, as stated
by various dictionary sources. For example, an argument frame of `Erg-Abs` indicates
that the verb takes two core arguments, the first marked with ergative case, 
and the second with absolutive (unmarked) case.

### Meanings

The fourth column of **lemmas.txt** shows the verb's meaning or meanings, as copied from
various dictionary sources. Among other uses, these meanings help to identify the difference
between lemmas that share the same form.

# Applying the Stylesheet

To create **verbs-with-lemmas.txt**, execute the following comm
`java -cp saxon9.jar:DictionarySearchStandalone.jar net.sf.saxon.Transform 
-s:dictionary.xml -xsl:verbs-with-lemmas.xsl -o:verbs-with-lemmas.txt`

The Wylie to Unicode converter that we are using is overly opinionated.
It thinks that the following Wylie syllables are illegal, despite the
obvious conversions:

1. *'krongs* > འཀྲོངས
2. *bjid* > བཇིད
3. *bnyags* > བཉགས
4. *bnab* > བནབ
5. *dphrog* > དཕྲོག
6. *gstsan* > གསྩན

Therefore the stylesheet handles these cases specially. (It also handles
the *da drag* specially.) If you produce *verbs-with-lemmas.txt* yourself,
search the file for the word *ERROR*. There shouldn't be errors, but if 
there are, then additional exceptions can be added to the stylesheet.

A similar procedure could probably be followed to produce **verbs-final.txt**.