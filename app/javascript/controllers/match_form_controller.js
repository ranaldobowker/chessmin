import { Controller } from "@hotwired/stimulus"

// Keeps the player 1 / player 2 selects mutually exclusive and limits the
// winner select to the two selected players.
export default class extends Controller {
  static targets = ["playerOne", "playerTwo", "winner"]

  connect() {
    this.update()
  }

  update() {
    this.excludeSelection(this.playerOneTarget, this.playerTwoTarget)
    this.excludeSelection(this.playerTwoTarget, this.playerOneTarget)
    this.updateWinnerOptions()
  }

  excludeSelection(sourceSelect, targetSelect) {
    for (const option of targetSelect.options) {
      option.disabled = option.value !== "" && option.value === sourceSelect.value
    }

    if (targetSelect.value !== "" && targetSelect.value === sourceSelect.value) {
      targetSelect.value = ""
    }
  }

  updateWinnerOptions() {
    const players = [this.playerOneTarget, this.playerTwoTarget]
      .filter((select) => select.value !== "")
      .map((select) => ({
        value: select.value,
        label: select.options[select.selectedIndex].text
      }))

    const winner = this.winnerTarget
    winner.innerHTML = ""

    if (players.length < 2) {
      winner.append(new Option("Select both players first", ""))
      winner.disabled = true
      return
    }

    winner.disabled = false
    winner.append(new Option("Select winner", ""))
    for (const player of players) {
      winner.append(new Option(player.label, player.value))
    }
  }
}
