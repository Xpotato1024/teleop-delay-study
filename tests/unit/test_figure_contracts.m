classdef test_figure_contracts < matlab.unittest.TestCase
    methods (Test)
        function testConditionMapUsesIndexCoordinatesAndStableMarkers(testCase)
            [classification, brackets] = test_figure_contracts.condition_fixture();
            first = teleopdelay.analysis.condition_map_layout(classification, brackets, "circle");
            permutation = [17:40, 1:16];
            second = teleopdelay.analysis.condition_map_layout(classification(permutation, :), brackets, "circle");
            expected = reshape(1:20, 4, 5).';
            testCase.verifyEqual(first.map, expected);
            testCase.verifyEqual(second.map, expected);
            testCase.verifyEqual(first.omega_index, 1:4);
            testCase.verifyEqual(first.delay_index, 1:5);
            testCase.verifyEqual(first.omegas, [0.5, 1, 2, 4]);
            testCase.verifyEqual(first.delays, [0, 0.1, 0.2, 0.4, 0.5]);
            testCase.verifyEqual(first.markers(1).lower_omega_index, 2);
            testCase.verifyEqual(first.markers(1).upper_omega_index, 2);
            testCase.verifyEqual(first.markers(1).lower_delay_index, 2);
            testCase.verifyEqual(first.markers(1).upper_delay_index, 3);
            testCase.verifyEqual(first.markers(1).x, [2, 2]);
            testCase.verifyEqual(first.markers(1).y, [2.25, 3.25]);
            testCase.verifyEqual(first.markers(1).lower_case_id, "circle-1-0p1");
            testCase.verifyEqual(height(first.selected_brackets), 1);
            testCase.verifyEqual(first.selected_brackets.bracket_type, "improvement-degradation");
        end

        function testConditionMapRejectsBoundaryValueOutsideGrid(testCase)
            [classification, brackets] = test_figure_contracts.condition_fixture();
            brackets.lower_delay_s(1) = 0.3;
            testCase.verifyError(@() teleopdelay.analysis.condition_map_layout( ...
                classification, brackets, "circle"), ...
                "teleopDelay:AnalysisBoundaryGridValueMissing");
        end

        function testConditionMapUsesSharedExternalLegendLayout(testCase)
            contract = teleopdelay.analysis.condition_map_visual_contract();
            testCase.verifyEqual(contract.legend_location, "southoutside");
            testCase.verifyEqual(contract.legend_orientation, "horizontal");
            legendTop = contract.legend_position(2) + contract.legend_position(4);
            axesBottom = contract.axes_position(2);
            testCase.verifyGreaterThan(contract.legend_position(2), 0);
            testCase.verifyLessThan(legendTop, axesBottom);
            testCase.verifyEqual(contract.legend_position(1), contract.axes_position(1));
            testCase.verifyEqual(contract.legend_position(3), contract.axes_position(3));
            testCase.verifyGreaterThan(contract.colorbar_position(1), ...
                contract.axes_position(1) + contract.axes_position(3));
            testCase.verifyGreaterThan(contract.axes_position(4), 0.60);
        end

        function testArchitectureContractHasRequiredAndNoForbiddenEdges(testCase)
            contract = teleopdelay.analysis.architecture_contract();
            expected = [
                "continuous_target" "sender_sampling"
                "sender_sampling" "fixed_delay"
                "fixed_delay" "latest_packet"
                "latest_packet" "zoh_reconstruction"
                "latest_packet" "cv_reconstruction"
                "zoh_reconstruction" "zoh_plant"
                "cv_reconstruction" "cv_plant"
                "continuous_target" "reference_plant"
                "reference_plant" "evaluation"
                "zoh_plant" "evaluation"
                "cv_plant" "evaluation"];
            testCase.verifyEqual(contract.required_edges, expected);
            testCase.verifyEmpty(intersect(string(contract.required_edges(:, 1)) + "->" + ...
                string(contract.required_edges(:, 2)), ...
                string(contract.forbidden_edges(:, 1)) + "->" + ...
                string(contract.forbidden_edges(:, 2))));
            testCase.verifyTrue(any(all(contract.required_edges == ["continuous_target", "reference_plant"], 2)));
            testCase.verifyEqual(sum(contract.required_edges(:, 2) == "evaluation"), 3);
            testCase.verifyFalse(any(all(contract.required_edges == ["latest_packet", "reference_plant"], 2)));
            testCase.verifyTrue(all(ismember(["continuous_target", "sender_sampling", ...
                "fixed_delay", "latest_packet", "zoh_reconstruction", "cv_reconstruction", ...
                "reference_plant", "zoh_plant", "cv_plant", "evaluation"], contract.nodes)));
            geometry = teleopdelay.analysis.architecture_geometry();
            testCase.verifyEmpty(geometry.crossings);
            testCase.verifyEqual(numel(geometry.edges), size(contract.required_edges, 1));
            cvEdge = arrayfun(@(edge) edge.source == "latest_packet" && ...
                edge.target == "cv_reconstruction", geometry.edges);
            testCase.verifyTrue(any(cvEdge));
            cvPoints = geometry.edges(cvEdge).points;
            testCase.verifyGreaterThanOrEqual(size(cvPoints, 1), 4);
            testCase.verifyEqual(cvPoints(1, 2), 0.70, "AbsTol", 1e-12);
            testCase.verifyEqual(cvPoints(end, 2), 0.30, "AbsTol", 1e-12);
            testCase.verifyGreaterThan(cvPoints(2, 1), 0.64);
            testCase.verifyLessThan(cvPoints(end - 1, 1), 0.66 + 1e-12);
            latestLabel = string(contract.labels(contract.nodes == "latest_packet"));
            testCase.verifyTrue(contains(latestLabel, "有効状態・パケット齢"));
            testCase.verifyFalse(contains(latestLabel, "valid状態"));
            testCase.verifyFalse(contains(latestLabel, "packet age"));
        end

        function testFigure08UsesAgeBasedCandidateLabels(testCase)
            figureText = teleopdelay.analysis.figure_text_contract().figure_08;
            testCase.verifyEqual(figureText.x_label, "ω × 平均パケット齢");
            testCase.verifyEqual(figureText.basic_candidate_legend, ...
                "理論候補（ω × 平均パケット齢 ≈ 1.895、実測境界ではない）");
            testCase.verifyEqual(figureText.double_candidate_legend, ...
                "理論候補（2ω × 平均パケット齢 ≈ 1.895、実測境界ではない）");
            testCase.verifyFalse(contains(string(figureText.x_label), "ωL"));
            testCase.verifyFalse(contains(string(figureText.basic_candidate_legend), "ωL"));
            testCase.verifyFalse(contains(string(figureText.double_candidate_legend), "ωL"));
        end

        function testEventDisplayIsSharedRugAndNonCausal(testCase)
            contract = teleopdelay.analysis.event_display_contract();
            testCase.verifyEqual(contract.upper_mode, "shared-rug");
            testCase.verifyEqual(contract.upper_label, "高加速度時刻");
            testCase.verifyNotEmpty(strfind(contract.note, "時間的一致"));
            testCase.verifyNotEmpty(strfind(contract.note, "因果関係を意味しない"));
        end

        function testAllFigureHumanFacingTextIsJapaneseAndTechnicalSymbolsRemain(testCase)
            contract = teleopdelay.analysis.figure_text_contract();
            fields = fieldnames(contract);
            allText = strings(0, 1);
            for index = 1:numel(fields)
                values = struct2cell(contract.(fields{index}));
                allText = [allText; string(values)]; %#ok<AGROW>
            end
            hasJapanese = ~cellfun(@isempty, regexp(cellstr(allText), "[ぁ-んァ-ヶ一-龯]", "once"));
            testCase.verifyTrue(all(hasJapanese));
            testCase.verifyTrue(any(contains(allText, "ZOH")));
            testCase.verifyTrue(any(contains(allText, "CV")));
            testCase.verifyTrue(any(contains(allText, "RMSE")));
            testCase.verifyTrue(any(contains(allText, "G")));
            testCase.verifyFalse(any(contains(lower(allText), ["reference", "sampled", "performance ratio", ...
                "time", "tracking error", "acceleration magnitude"])));
            titles = [string(contract.figure_01.title); string(contract.figure_02.title); ...
                string(contract.figure_03.title); string(contract.figure_04.title); ...
                string(contract.figure_05.title); string(contract.figure_06.title); ...
                string(contract.figure_07.title); string(contract.figure_08.title)];
            captions = [string(contract.figure_01.caption); string(contract.figure_02.caption); ...
                string(contract.figure_03.caption); string(contract.figure_04.caption); ...
                string(contract.figure_05.caption); string(contract.figure_06.caption); ...
                string(contract.figure_07.caption); string(contract.figure_08.caption)];
            titleJapanese = ~cellfun(@isempty, regexp(cellstr(titles), "[ぁ-んァ-ヶ一-龯]", "once"));
            captionJapanese = ~cellfun(@isempty, regexp(cellstr(captions), "[ぁ-んァ-ヶ一-龯]", "once"));
            testCase.verifyTrue(all(titleJapanese));
            testCase.verifyTrue(all(captionJapanese));
        end

        function testJapaneseFontSelectionIsStable(testCase)
            fig = figure("Visible", "off");
            cleanup = onCleanup(@() close(fig));
            fontName = teleopdelay.analysis.style_figure(fig);
            testCase.verifyTrue(ismember(fontName, ["Yu Gothic", "Meiryo", "Noto Sans CJK JP", "Noto Sans JP"]));
            clear cleanup;
        end
    end

    methods (Static, Access=private)
        function [classification, brackets] = condition_fixture()
            omegas = [0.5, 1, 2, 4];
            delays = [0, 0.1, 0.2, 0.4, 0.5];
            [omegaGrid, delayGrid] = ndgrid(omegas, delays);
            omegaValues = omegaGrid(:);
            delayValues = delayGrid(:);
            trajectory = repmat("circle", 20, 1);
            caseId = strings(20, 1);
            for index = 1:20
                caseId(index) = "circle-" + string(omegaValues(index)) + "-" + string(delayValues(index));
            end
            ratios = (1:20).';
            classification = table(caseId, trajectory, omegaValues, delayValues, ratios(:), ...
                'VariableNames', {'case_id', 'trajectory', 'omega_rad_s', 'delay_s', 'performance_ratio'});
            classification = [classification; classification];
            classification.case_id(21:end) = "lissajous-" + string((1:20).');
            classification.trajectory(21:end) = "lissajous_1_2";
            brackets = table( ...
                ["circle"; "circle"], ["improvement-degradation"; "nearest-G-pair"], ...
                [0.1; 0.4], [0.2; 0.5], [1; 1], [1; 2], ...
                ["circle-1-0p1"; "circle-1-0p4"], ["circle-1-0p2"; "circle-2-0p5"], ...
                'VariableNames', {'trajectory', 'bracket_type', 'lower_delay_s', ...
                'upper_delay_s', 'lower_omega_rad_s', 'upper_omega_rad_s', ...
                'lower_case_id', 'upper_case_id'});
        end
    end
end
