sidebarNodes={"extras":[{"id":"api-reference","title":"API Reference","group":"","headers":[{"id":"Modules","anchor":"modules"}]}],"exceptions":[],"modules":[{"id":"BrettProjekt.Application","title":"BrettProjekt.Application","functions":[{"id":"start/2","anchor":"start/2"}]},{"id":"BrettProjekt.Game","title":"BrettProjekt.Game"},{"id":"BrettProjekt.Game.EndGame","title":"BrettProjekt.Game.EndGame"},{"id":"BrettProjekt.Game.Lobby","title":"BrettProjekt.Game.Lobby","functions":[{"id":"add_player/2","anchor":"add_player/2"},{"id":"create_game/1","anchor":"create_game/1"},{"id":"set_ready/3","anchor":"set_ready/3"},{"id":"switch_team/3","anchor":"switch_team/3"}],"types":[{"id":"lobby_state/0","anchor":"t:lobby_state/0"},{"id":"player_id/0","anchor":"t:player_id/0"},{"id":"team/0","anchor":"t:team/0"},{"id":"team_id/0","anchor":"t:team_id/0"}]},{"id":"BrettProjekt.Game.LobbyStateTransformation","title":"BrettProjekt.Game.LobbyStateTransformation","functions":[{"id":"get_team_players/2","anchor":"get_team_players/2"},{"id":"transform/1","anchor":"transform/1"}]},{"id":"BrettProjekt.Game.Round","title":"BrettProjekt.Game.Round","functions":[{"id":"answer_questions/3","anchor":"answer_questions/3"}]},{"id":"BrettProjekt.Game.RoundEvaluation","title":"BrettProjekt.Game.RoundEvaluation"},{"id":"BrettProjekt.Game.RoundPreparation","title":"BrettProjekt.Game.RoundPreparation","functions":[{"id":"set_player_categories/3","anchor":"set_player_categories/3"}]},{"id":"BrettProjekt.Game.RoundPreparationStateTransformation","title":"BrettProjekt.Game.RoundPreparationStateTransformation","functions":[{"id":"transform/2","anchor":"transform/2"}]},{"id":"BrettProjekt.GameManager","title":"BrettProjekt.GameManager","functions":[{"id":"add_game/2","anchor":"add_game/2"},{"id":"add_new_game/1","anchor":"add_new_game/1"},{"id":"generate_game_id/1","anchor":"generate_game_id/1"},{"id":"get_game_by_id/2","anchor":"get_game_by_id/2"},{"id":"get_games/1","anchor":"get_games/1"},{"id":"start_link/0","anchor":"start_link/0"},{"id":"start_link/1","anchor":"start_link/1"}]},{"id":"BrettProjekt.MonadUtil","title":"BrettProjekt.MonadUtil","functions":[{"id":"unwrap/1","anchor":"unwrap/1"}]},{"id":"BrettProjekt.Question.Parser.V1_0","title":"BrettProjekt.Question.Parser.V1_0","functions":[{"id":"parse/1","anchor":"parse/1"},{"id":"to_question_struct/1","anchor":"to_question_struct/1"},{"id":"to_question_structs/1","anchor":"to_question_structs/1"}]},{"id":"BrettProjekt.Question.Server","title":"BrettProjekt.Question.Server","functions":[{"id":"get_categories/1","anchor":"get_categories/1"},{"id":"get_question/2","anchor":"get_question/2"},{"id":"get_questions/1","anchor":"get_questions/1"},{"id":"load_questions_from_file/2","anchor":"load_questions_from_file/2"},{"id":"load_questions_from_json/2","anchor":"load_questions_from_json/2"},{"id":"start_link/0","anchor":"start_link/0"},{"id":"start_link/1","anchor":"start_link/1"}]},{"id":"BrettProjekt.Question.ServerManager","title":"BrettProjekt.Question.ServerManager","functions":[{"id":"get_question_server/1","anchor":"get_question_server/1"},{"id":"load_questions_from_file/2","anchor":"load_questions_from_file/2"},{"id":"start_link/0","anchor":"start_link/0"},{"id":"start_link/1","anchor":"start_link/1"},{"id":"start_link/2","anchor":"start_link/2"}]},{"id":"BrettProjekt.Question.Type.FillIn","title":"BrettProjekt.Question.Type.FillIn","functions":[{"id":"parse/1","anchor":"parse/1"},{"id":"validate_answer/2","anchor":"validate_answer/2"}]},{"id":"BrettProjekt.Question.Type.List","title":"BrettProjekt.Question.Type.List","functions":[{"id":"parse/1","anchor":"parse/1"},{"id":"validate_answer/2","anchor":"validate_answer/2"}]},{"id":"BrettProjekt.Question.Type.MultipleChoice","title":"BrettProjekt.Question.Type.MultipleChoice","functions":[{"id":"parse/1","anchor":"parse/1"},{"id":"validate_answer/2","anchor":"validate_answer/2"}]},{"id":"BrettProjekt.Question.Type.Wildcard","title":"BrettProjekt.Question.Type.Wildcard","functions":[{"id":"parse/1","anchor":"parse/1"},{"id":"validate_answer/2","anchor":"validate_answer/2"}]},{"id":"BrettProjekt.Web","title":"BrettProjekt.Web","functions":[{"id":"__using__/1","anchor":"__using__/1"},{"id":"channel/0","anchor":"channel/0"},{"id":"controller/0","anchor":"controller/0"},{"id":"router/0","anchor":"router/0"},{"id":"view/0","anchor":"view/0"}]},{"id":"BrettProjekt.Web.Endpoint","title":"BrettProjekt.Web.Endpoint","functions":[{"id":"__sockets__/0","anchor":"__sockets__/0"},{"id":"broadcast/3","anchor":"broadcast/3"},{"id":"broadcast!/3","anchor":"broadcast!/3"},{"id":"broadcast_from/4","anchor":"broadcast_from/4"},{"id":"broadcast_from!/4","anchor":"broadcast_from!/4"},{"id":"call/2","anchor":"call/2"},{"id":"config/2","anchor":"config/2"},{"id":"config_change/2","anchor":"config_change/2"},{"id":"host/0","anchor":"host/0"},{"id":"init/1","anchor":"init/1"},{"id":"instrument/3","anchor":"instrument/3"},{"id":"load_from_system_env/1","anchor":"load_from_system_env/1"},{"id":"path/1","anchor":"path/1"},{"id":"script_name/0","anchor":"script_name/0"},{"id":"start_link/0","anchor":"start_link/0"},{"id":"static_path/1","anchor":"static_path/1"},{"id":"static_url/0","anchor":"static_url/0"},{"id":"struct_url/0","anchor":"struct_url/0"},{"id":"subscribe/1","anchor":"subscribe/1"},{"id":"subscribe/3","anchor":"subscribe/3"},{"id":"unsubscribe/1","anchor":"unsubscribe/1"},{"id":"url/0","anchor":"url/0"}]},{"id":"BrettProjekt.Web.ErrorHelpers","title":"BrettProjekt.Web.ErrorHelpers","functions":[{"id":"translate_error/1","anchor":"translate_error/1"}]},{"id":"BrettProjekt.Web.ErrorView","title":"BrettProjekt.Web.ErrorView","functions":[{"id":"__phoenix_recompile__?/0","anchor":"__phoenix_recompile__?/0"},{"id":"__resource__/0","anchor":"__resource__/0"},{"id":"__templates__/0","anchor":"__templates__/0"},{"id":"render/2","anchor":"render/2"},{"id":"template_not_found/2","anchor":"template_not_found/2"}]},{"id":"BrettProjekt.Web.GameChannel","title":"BrettProjekt.Web.GameChannel","functions":[{"id":"code_change/3","anchor":"code_change/3"},{"id":"handle_in/3","anchor":"handle_in/3"},{"id":"handle_info/2","anchor":"handle_info/2"},{"id":"terminate/2","anchor":"terminate/2"}]},{"id":"BrettProjekt.Web.Gettext","title":"BrettProjekt.Web.Gettext","functions":[{"id":"dgettext/3","anchor":"dgettext/3"},{"id":"dgettext_noop/2","anchor":"dgettext_noop/2"},{"id":"dngettext/5","anchor":"dngettext/5"},{"id":"dngettext_noop/3","anchor":"dngettext_noop/3"},{"id":"gettext/2","anchor":"gettext/2"},{"id":"gettext_noop/1","anchor":"gettext_noop/1"},{"id":"handle_missing_bindings/2","anchor":"handle_missing_bindings/2"},{"id":"lgettext/4","anchor":"lgettext/4"},{"id":"lngettext/6","anchor":"lngettext/6"},{"id":"ngettext/4","anchor":"ngettext/4"},{"id":"ngettext_noop/2","anchor":"ngettext_noop/2"}]},{"id":"BrettProjekt.Web.MainChannel","title":"BrettProjekt.Web.MainChannel","functions":[{"id":"code_change/3","anchor":"code_change/3"},{"id":"handle_in/3","anchor":"handle_in/3"},{"id":"handle_info/2","anchor":"handle_info/2"},{"id":"join/3","anchor":"join/3"},{"id":"terminate/2","anchor":"terminate/2"}]},{"id":"BrettProjekt.Web.Router","title":"BrettProjekt.Web.Router","functions":[{"id":"api/2","anchor":"api/2"},{"id":"call/2","anchor":"call/2"},{"id":"init/1","anchor":"init/1"}]},{"id":"BrettProjekt.Web.Router.Helpers","title":"BrettProjekt.Web.Router.Helpers","functions":[{"id":"path/2","anchor":"path/2"},{"id":"static_path/2","anchor":"static_path/2"},{"id":"static_url/2","anchor":"static_url/2"},{"id":"url/1","anchor":"url/1"}]},{"id":"BrettProjekt.Web.UserSocket","title":"BrettProjekt.Web.UserSocket","functions":[{"id":"connect/2","anchor":"connect/2"},{"id":"id/1","anchor":"id/1"}]}],"protocols":[],"tasks":[]}