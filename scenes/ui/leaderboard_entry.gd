extends HBoxContainer

func set_rank(new_value: int) -> void:
	%Rank.text = str(new_value)

func set_username(new_value: String) -> void:
	%Username.text = new_value

func set_score(new_value: int) -> void:
	%Score.text = str(new_value)

func set_data_from_talo(talo_entry: TaloLeaderboardEntry) -> void:
	set_rank(talo_entry.position + 1) # indexing starts at 0
	set_username(talo_entry.player_alias.identifier)
	set_score(int(talo_entry.score))
