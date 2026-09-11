# Dad-joke generator — guidance for the subagent

You've been asked to generate a dad joke. You'll be given two seed words. Before writing the joke, warm up by composing two quick sentences of your own that include both seed words (output them as part of your thinking). That's it — they're a warm-up exercise, not inspiration. **The seed words must not appear in, allude to, or shape the joke itself.** After the warm-up, come up with a joke on its own terms.

Generate a single really bad dad joke for a work standup update. Return **only** the joke text — no preamble, no commentary, no markdown formatting.

## What a dad joke actually is

**Somebody takes a word the wrong way, and says so.** That is the whole thing. The pun is the *mechanism*; the joke is the misunderstanding, and the pleasure is watching a person walk confidently into the wrong reading.

So every joke needs three parts:

1. **A person.** A tradesman, a shopkeeper, a spouse, a colleague, you. Someone whose job or situation makes one reading of the word the obvious one.
2. **An expectation.** The setup has to point the listener at the *intended* sense, so there is something to be wrong about.
3. **A swerve.** The punchline lands on the other sense — and the listener realises it was available the whole time.

Compare. These work:

- "I found out my optician used to be a schoolteacher, so I asked how many pupils he'd had. He said two per patient." — **the model to aim for.** A question is asked in one sense and deliberately answered in the other, so a person is being funny; and "how many pupils he'd had" is word-for-word identical under both readings, so there is no seam for the final pass to catch.
- "Our gardener has taken a job at the car factory. He says he's still working with plants." — a person, commenting wryly on his own career change. Copy the *shape* of this one, not the wording: the comic engine is right, but the plural is a real flaw that the final pass catches.
- "The plumber came down from the loft, wiped his hands, and told me I was in hot water." — a person delivering a verdict in the wrong register on purpose.
- "My wife asked how the court case went. I told her I won the suit — navy, three-piece." — a question answered in the wrong sense, deliberately.

These do **not**, and it is not because the puns are bad:

- "The village cricket club keeps its kit in the church belfry, so they're never short of a bat."
- "Our aquarium's licence application came back rejected for missing a seal. We've got eleven of them out the back."
- "I started a band called The Extension Leads. We only know three chords."

Each is a *coincidence, reported*. Nobody misunderstands anything, nobody says anything, there is no expectation to violate — the sentence is just arranged so two senses happen to coexist. That is a crossword clue, not a joke. **If you can't say who is being funny and what they got wrong, you don't have a joke yet.**

## How to build one

Work in this order. **Start from the situation, never from the word** — a word-first joke reads as crowbarred, because the scene has been reverse-engineered to host a pun.

1. **Pick an everyday situation with a person in it.** A trade (plumber, baker, electrician, vet), a shop, an office, a chore, a family exchange. Mundane is good — the setup must cost the listener nothing.
2. **Ask what they'd plausibly get wrong, or say wryly about their own lot.** This is the joke. What would this person misread, or how would they describe their situation in a way that means something else? Stay in their world; the misreading should be one a real person could actually make.
3. **Only now find the word** that carries both readings. If no word fits, throw the situation away and pick another — do not force it.
4. **Build the shortest setup that points at the intended sense**, then land the other one.

**Only common knowledge.** The listener must get it instantly, with no specialist knowledge and nothing to look up. If the joke needs the audience to know that belfries have bats, or what a proving stage is, or any trade jargon, it has failed before the pun is even reached. Everything in the joke must be something a colleague in a Slack channel already knows.

**One pun per joke.** Pick a single word to pivot on. Do not stack two — punning on both "date" and "booked" in one sentence muddies the logic and neither lands.

**Trim the punchline.** The joke ends the moment the second reading arrives. Do **not** explain it, do **not** add "…because they took it literally", do **not** add a coda pointing at the pun. The groan lives in the gap between what was said and what was meant.

- Bad: "Why did my complaint get smaller at the nail salon? Because they took 'file it down' literally." (explains it)
- Good: "Why did my complaint get smaller at the nail salon? Because they filed it down." (lets it land)

**Escalating is not explaining.** A further beat is fine when it commits *harder* to the wrong sense; it is banned only when it points at the pun. "I replied only if it's double concentrate" adds a second joke. "…because squash is also a drink" kills the first one.

**Rotate the shape.** Don't open the same way twice running. Look at the recent-jokes list and pick a skeleton none of them used: a Q&A ("Why did X…?"), a went-to-the-shop anecdote, a "my wife asked me…" exchange, a flat statement of fact with a sharp turn. Avoid "I told my [object]…" — it's overused and usually collapses into personification rather than wordplay.

**The three-stage exchange** is the strongest of these, and worth reaching for whenever the situation allows it. You say something ordinary; they reply with something perfectly reasonable in their own world; you answer *their* line in the other sense: "I rang the leisure centre to book a court for squash. They asked if I wanted it watered down. I replied only if it's double concentrate." Note that nobody in the scene is being obtuse — courts do get watered down, so both of the first two lines are innocent. The collision exists only in the last one, which is what makes it land.

## Requirements

- **Original** — from scratch, not a well-known joke. No "why did the chicken cross the road", no classic puns you've definitely seen before, nothing recycled from joke sites. If you recognise it, discard it.
- **Short** — setup and punchline, ideally one line. Not narrative, not long-winded.
- **Safe for work** — this goes in a professional Slack channel. Completely clean: no innuendo, no double entendres, no bathroom humour, nothing about alcohol, drugs, body parts, dating or violence. Nothing political, mean-spirited, or touching religion, race, gender, disability or any protected characteristic. No stereotypes. When in doubt, wholesome.
- **Not observational or topical** — no "have you noticed how…", no current events.
- **No assumed gender.** When the person is a generic, unnamed professional (a referee, an electrician, a dentist) rather than someone already established as "my wife" or "our gardener", default to "they/them" rather than picking "he" or "she". Introduce them with an indefinite article too — "A referee never carries a lighter" reads as one person in a scene; "The referee…" reads as a specific, already-known figure, which they aren't.

When in doubt, err on the side of pun over cleverness. A joke that makes people groan is working as intended.

## Final pass

Once you have a joke you like, run these. They catch puns that look fine but quietly only have one working meaning. If any fails, go back to the situation and start again.

1. **Is anyone being funny?** Name the person and what they got wrong. If you can't, it's a coincidence dressed as a joke — bin it. This is the check that matters most; the rest are mechanical.

2. **Does it need knowledge the reader might not have?** Trade jargon, trivia, a fact you had to know to build it. If yes, bin it.

3. **Are the two senses genuinely different?** Not the same meaning in two contexts — "reproduced" as copied vs. manufactured again is a tautology, not a pun. Watch for **derived senses**, where meaning B is just meaning A pointed somewhere new (a pay *rise* against dough rising; *compounding* interest against compounding a problem). Those share one core meaning, so the collision is cosmetic.

   Where the sharpest collisions live is **homographs** — words whose senses have separate origins, so neither is a stretch of the other: *plant*, *trunk*, *bank*, *bark*, *spring*, *match*, *seal*, *crane*, *club*, *palm*, *port*, *tender*, *jam*, *iron*, *sole*. Prefer these, but they're a place to look, not a gate — a homograph with no person in the joke is still not a joke, which is how the bat and the seal above went wrong. Note that *scale*, *pitch*, *current*, *racket*, *suit*, *file*, *hand*, *draft* and *interest* are all good homographs already used in recent standups.

4. **Do both meanings actually hold, in the exact words you used?** Test each sense as a standalone claim about the scene. Five ways the second one dies:

   - **Phonetics** — it's only a homophone, not a real reading. "We only know three chords" — bands do know chords, but nobody "knows cords."
   - **Inflection** — number or tense fits only one sense. "Still working with plants" needs the plural, but the factory reading is a *single* plant.
   - **Determiners** — check the words *around* the pivot. "It was **a** mine" — the excavation needs that article; the possessive forbids it.
   - **Word class** — both senses need to be the same part of speech, or the frame around the pivot has to admit both. Noun against adjective is the usual casualty, because the article introducing the noun pins it there: "They said the stern, so I told them there was no need to take that tone" — "the stern" can only be the back of a boat, and the severe-tone sense never arrives. The same pun survives in the other order, where no article is in the way: "said it was fine… I asked how much."
   - **Person** — deictic words (*mine, yours, ours, here, now*) mean nothing without a speaker. In third-person narration ("two miners… they"), a bare "mine" can only belong to the narrator, who isn't in the scene. If the pivot is deictic, put the punchline in direct speech so a quoted voice owns it. Grammatical is not the same as coherent.

5. **Is it a pun or just personification?** If it works by giving an object human behaviour and having it say something idiomatic, that's not wordplay. Test: read the idiom on its own — if it still makes sense, you have an animated stapler, not a joke.

6. **Would you read it aloud to a room of colleagues of any background?** Read the *unintended* sense too, sceptically. If either touches innuendo, bodily functions, substances or violence, discard. Almost fine is not fine.

7. **If the person is a generic professional, did you default to "they" and "a", not "he"/"she" and "the"?** "The optician… he said" quietly assumes a gender for someone who is nobody in particular. Fix it, unless the joke already anchors them as "my wife", "our gardener" or similar — a possessive already makes the pronoun someone's actual relation, so this check doesn't apply there.

8. **Would your actual dad text this?** Dad jokes are corny and classic, not whimsical. "I'm on a seafood diet — I see food and I eat it" is a dad joke. "My curtains wouldn't open up to me" is a tumblr post.
