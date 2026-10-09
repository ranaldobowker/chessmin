import { Controller } from "@hotwired/stimulus"

// Keeps the player 1 / player 2 selects mutually exclusive and limits the
// result select to the two selected players or a draw.
export default class extends Controller {
  static targets = ["playerOne", "playerTwo", "result"]

  connect() {
    this.update()
  }

  update() {
    this.excludeSelection(this.playerOneTarget, this.playerTwoTarget)
    this.excludeSelection(this.playerTwoTarget, this.playerOneTarget)
    this.updateResultOptions()
  }

  excludeSelection(sourceSelect, targetSelect) {
    for (const option of targetSelect.options) {
      option.disabled = option.value !== "" && option.value === sourceSelect.value
    }

    if (targetSelect.value !== "" && targetSelect.value === sourceSelect.value) {
      targetSelect.value = ""
    }
  }

  updateResultOptions() {
    const players = [
      { element: this.playerOneTarget, value: "player_one" },
      { element: this.playerTwoTarget, value: "player_two" }
    ]
      .filter(({ element }) => element.value !== "")
      .map(({ element, value }) => ({
        value,
        label: element.options[element.selectedIndex].text
      }))

    const result = this.resultTarget
    result.innerHTML = ""

    if (players.length < 2) {
      result.append(new Option("Select both players first", ""))
      result.disabled = true
      return
    }

    result.disabled = false
    result.append(new Option("Select result", ""))
    for (const player of players) {
      result.append(new Option(player.label, player.value))
    }
    result.append(new Option("Draw", "draw"))
  }
}
