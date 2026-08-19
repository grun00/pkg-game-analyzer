# WhiplashGameStats

> A terminal-themed app for tracking and analyzing your Pokémon TCG matches.

WhiplashGameStats is a Ruby on Rails 7.2 application that lets competitive Pokémon
Trading Card Game players log their games and turn raw match history into actionable
insights. Every screen is styled as a retro CRT/terminal interface
(monospace `VT323` typography, phosphor-green accents, and bracketed `[ ACTIONS ]`)
that makes reviewing your play feel like operating a handheld battle computer.

---

## Project Overview

Serious TCG improvement depends on honest record keeping: *which decks are beating you,
how good your opening hands actually are, and whether you perform better going first or
second.* WhiplashGameStats centralizes all of that.

Players organize their games into **dashboards** (for example, one per format,
tournament, or deck they are piloting). Each dashboard aggregates its **matches** into a
live analytics view, so the moment a game is logged the win rates, matchup spreads, and
turn-order splits update automatically.

The **WhiplashGameStats** interface presents this data as a competitive command console —
summary stat cards, a per-deck results table with inline win-rate bars, and a scrolling
match log — keeping the focus on the numbers that drive better deckbuilding and play.

---

## Key Features

### Match Logging
Capture the details that matter for post-game analysis:

- **Result** — `win` / `loss`.
- **Opponent deck archetype** — a curated enum (`OPPONENT_DECKS`) covering the current
  metagame, including archetypes such as `dragapult`, `mega_lucario`, `mega_starmie`,
  `raging_bolt`, `greninja_ex`, `mega_excadrill`, and an `other` catch-all.
- **Initial hand quality** — a 1–5 star rating of your opening hand.
- **Turn order** — went `first`, `second`, or `uninformed`.
- **Number of mulligans** — optional integer count.
- **Reason for defeat** — for losses: `minor_misplay`, `major_misplay`, `disconnected`,
  `unlucky`, or `unknown`.
- **Free-form notes** — describe how the game actually played out.

### Analytics Dashboard
Powered by `MatchStatsService`, each dashboard surfaces:

- **Headline stats** — total matches, wins, losses, overall win rate, and average hand
  quality.
- **Results by opponent deck** — per-archetype totals, W/L, win percentage, and a
  first-vs-second breakdown, sorted by how often you have faced each deck.
- **Going first vs. second** — aggregate win rates for each turn order.
- **Defeat-reason breakdown** — where your losses are coming from.
- **Recent match history** — a quick log of your latest games.

### Accounts & Data Isolation
User authentication is handled by **Devise**, and matches are scoped to a user's own
dashboards so each trainer sees only their own data.

---

## Technical Stack

| Layer            | Technology                                             |
| ---------------- | ------------------------------------------------------ |
| Language         | Ruby 3.2.2                                              |
| Framework        | Ruby on Rails 7.2                                       |
| Database         | PostgreSQL (`pg`)                                       |
| Front-end        | Hotwire — Turbo + Stimulus, Import Maps, Sprockets      |
| Web server       | Puma                                                    |
| Authentication   | Devise                                                  |
| Domain logic     | `MatchStatsService` (plain Ruby service object)         |
| Testing          | RSpec, FactoryBot, Shoulda Matchers, Faker              |
| Static analysis  | Brakeman, RuboCop (rails-omakase)                       |

**Domain model.** The core `Match` model uses ActiveRecord enums for
`opponent_deck`, `result`, `first_or_second`, and `reason_for_defeat`. Aggregation is
deliberately kept out of the model and controllers: `MatchStatsService` takes a
collection of matches and returns a single hash of computed statistics that the
dashboard view renders directly.

---

## Getting Started

### Prerequisites
- Ruby **3.2.2** (see `.ruby-version`)
- PostgreSQL **9.3+** running locally
- Bundler (`gem install bundler`)

### Setup

```bash
# 1. Clone the repository
git clone <your-repo-url> pkm_game_analyzer
cd pkm_game_analyzer

# 2. Install dependencies, prepare the database, and clear temp files in one step
bin/setup
```

`bin/setup` is idempotent — it installs gems (`bundle install`), runs
`bin/rails db:prepare` (create + migrate + seed), and clears logs/tempfiles.

### Manual setup (alternative)

If you prefer to run the steps individually:

```bash
bundle install
bin/rails db:create
bin/rails db:migrate
```

### Running the server

```bash
bin/rails server
```

Then open <http://localhost:3000>. Create an account via the Devise sign-up flow, add a
dashboard, and start logging matches.

### Database configuration

Connection settings live in `config/database.yml`. Development and test use local
databases (`pkm_game_analyzer_development` / `pkm_game_analyzer_test`). In production the
app reads a full connection string from the `DATABASE_URL` environment variable.

---

## Testing

The suite is written with **RSpec** and supported by FactoryBot, Shoulda Matchers, and
Faker. Model, request, and service specs live under `spec/`.

```bash
# Run the full test suite
bundle exec rspec

# Run a single file
bundle exec rspec spec/models/match_spec.rb

# Run a single example by line number
bundle exec rspec spec/services/match_stats_service_spec.rb:42
```

If it is your first run, make sure the test database is prepared:

```bash
bin/rails db:test:prepare
```

### Static analysis (optional)

```bash
bin/brakeman --no-pager   # security scan
bundle exec rubocop       # style (rails-omakase)
```

---

## Configuration

### Adding a new opponent deck archetype

Supported archetypes are defined by the `OPPONENT_DECKS` enum in
`app/models/match.rb`. Because `opponent_deck` is stored as an integer, every key maps
to a **stable, unique integer** — never reuse or renumber existing values, and pick the
next unused integer for additions.

```ruby
# app/models/match.rb
OPPONENT_DECKS = {
  dragapult:       0,
  # ...
  mega_excadrill:  26,
  new_archetype:   27,   # <-- add your new deck with the next free integer
  other:           15
}.freeze
```

After adding a key:

1. No migration is required — the column already stores the integer value.
2. The new archetype is picked up automatically everywhere it is needed: the match
   form's deck dropdown, the dashboard's per-deck stats, and the match log all derive
   their labels from `Match::OPPONENT_DECKS` via `humanize` (so `new_archetype` renders
   as "New archetype").
3. Update the expected-decks list in `spec/models/match_spec.rb` so the enum spec stays
   in sync, then run `bundle exec rspec spec/models/match_spec.rb`.

The same pattern applies to the other enums in `Match` (`result`, `first_or_second`,
and `reason_for_defeat`).
