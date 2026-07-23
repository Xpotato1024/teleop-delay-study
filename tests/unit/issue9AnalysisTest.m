classdef issue9AnalysisTest < matlab.unittest.TestCase
    % issue9AnalysisTest  Focused Issue #9 analysis contract tests.

    methods (TestClassSetup)
        function addSource(testCase)
            root = issue9AnalysisTest.projectRoot();
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(root));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root, "src")));
        end
    end

    methods (Test)
        function testTheoryExcludesTrivialRoot(testCase)
            result = teleopdelay.analysis.theory();
            testCase.verifyGreaterThan(result.q_candidate, 0.1);
            testCase.verifyEqual(result.q_candidate, 1.895494267, AbsTol=2e-8);
            testCase.verifyEqual(result.zoh_error_squared(0), 0, AbsTol=1e-14);
            testCase.verifyEqual(result.cv_error_squared(0), 0, AbsTol=1e-14);
            testCase.verifyEqual(result.zoh_error_squared(0.7), ...
                2 * (1 - cos(0.7)), AbsTol=1e-14);
            testCase.verifyEqual(result.cv_error_squared(0.7), ...
                (1 - cos(0.7))^2 + (0.7 - sin(0.7))^2, AbsTol=1e-14);
        end

        function testClassificationBoundaryAndSign(testCase)
            aggregate = issue9AnalysisTest.classificationFixture([0.5, 1.0, 1.5]);
            result = teleopdelay.analysis.classify(aggregate, 0.1);
            testCase.verifyEqual(result.classification, ["improvement"; "equivalent"; "degradation"]);
            testCase.verifyTrue(all(result.improvement_sign_consistent));
            testCase.verifyEqual(result.boundary_tolerance, repmat(0.1, 3, 1), AbsTol=0);
        end

        function testSelectionIsPermutationInvariant(testCase)
            aggregate = issue9AnalysisTest.classificationFixture([0.4, 0.4, 1.2, 1.2]);
            classification = teleopdelay.analysis.classify(aggregate, 1e-12);
            input = issue9AnalysisTest.selectionInput(classification);
            first = teleopdelay.analysis.select_representatives(input, classification, ...
                teleopdelay.analysis.default_config());
            permutation = [4, 2, 1, 3];
            second = teleopdelay.analysis.select_representatives(input, classification(permutation, :), ...
                teleopdelay.analysis.default_config());
            first = sortrows(first, {'trajectory', 'role'});
            second = sortrows(second, {'trajectory', 'role'});
            testCase.verifyEqual(first.case_id, second.case_id);
            testCase.verifyEqual(first.selection_reason, second.selection_reason);
        end

        function testAdjacentBoundaryDoesNotUseNonAdjacentPair(testCase)
            aggregate = issue9AnalysisTest.classificationFixture([0.5, 0.8, 1.2, 0.6]);
            aggregate.trajectory = ["circle"; "circle"; "circle"; "lissajous_1_2"];
            aggregate.delay_s = [0; 0.1; 0.2; 0];
            aggregate.omega_rad_s = [1; 1; 1; 1];
            classification = teleopdelay.analysis.classify(aggregate, 1e-12);
            result = teleopdelay.analysis.detect_boundaries(classification, ...
                teleopdelay.analysis.theory(), teleopdelay.analysis.default_config());
            direct = result(result.bracket_type == "improvement-degradation", :);
            testCase.verifyEqual(height(direct), 1);
            testCase.verifyEqual(direct.lower_delay_s(1), 0.1, AbsTol=0);
            testCase.verifyEqual(direct.upper_delay_s(1), 0.2, AbsTol=0);
        end

        function testValidFixtureInput(testCase)
            file = issue9AnalysisTest.writeFixture(testCase, "valid");
            input = teleopdelay.analysis.load_input(file);
            testCase.verifyEqual(height(input.aggregate), 40);
            testCase.verifyEqual(input.metadata.success_case_count, 40);
            testCase.verifyEqual(strlength(input.source_mat_sha256), 64);
        end

        function testMissingFieldRejected(testCase)
            file = issue9AnalysisTest.writeFixture(testCase, "missing-metadata");
            testCase.verifyError(@() teleopdelay.analysis.load_input(file), ...
                "teleopDelay:AnalysisInputSchemaMismatch");
        end

        function testFailedStatusRejected(testCase)
            file = issue9AnalysisTest.writeFixture(testCase, "failed-status");
            testCase.verifyError(@() teleopdelay.analysis.load_input(file), ...
                "teleopDelay:AnalysisInputIncomplete");
        end

        function testDuplicateCaseRejected(testCase)
            file = issue9AnalysisTest.writeFixture(testCase, "duplicate-case-id");
            testCase.verifyError(@() teleopdelay.analysis.load_input(file), ...
                "teleopDelay:AnalysisInputDuplicateCase");
        end

        function testInvalidMetricRejected(testCase)
            file = issue9AnalysisTest.writeFixture(testCase, "nan-metric");
            testCase.verifyError(@() teleopdelay.analysis.load_input(file), ...
                "teleopDelay:AnalysisInputMetricInvalid");
        end

        function testAggregateCaseMismatchRejected(testCase)
            file = issue9AnalysisTest.writeFixture(testCase, "aggregate-mismatch");
            testCase.verifyError(@() teleopdelay.analysis.load_input(file), ...
                "teleopDelay:AnalysisInputSchemaMismatch");
        end

        function testRenderOnlyDeterminismWithoutSimulation(testCase)
            file = issue9AnalysisTest.writeFixture(testCase, "valid");
            before = path;
            here = pwd;
            first = run_issue9_analysis("InputMat", file, "Mode", "render-only", "SaveResults", false);
            second = run_issue9_analysis("InputMat", file, "Mode", "render-only", "SaveResults", false);
            testCase.verifyEqual(first.analysis.analysis_id, second.analysis.analysis_id);
            testCase.verifyEqual(first.analysis.tables.representative_cases.case_id, ...
                second.analysis.tables.representative_cases.case_id);
            testCase.verifyEqual(first.analysis.tables.boundary_brackets, ...
                second.analysis.tables.boundary_brackets);
            testCase.verifyEqual(path, before);
            testCase.verifyEqual(pwd, here);
        end

        function testHeadlessFigureSetAndNoOpenFigures(testCase)
            file = issue9AnalysisTest.writeFixture(testCase, "valid");
            outputRoot = string(tempname);
            mkdir(outputRoot);
            testCase.addTeardown(@() rmdir(outputRoot, "s"));
            result = run_issue9_analysis("InputMat", file, "Mode", "render-only", ...
                "OutputRoot", outputRoot, "SaveResults", true);
            testCase.verifyEqual(height(result.artifact.figure_manifest), 8);
            testCase.verifyTrue(all(result.artifact.figure_manifest.vector_pdf));
            testCase.verifyTrue(all(result.artifact.figure_manifest.file_size_png > 0));
            testCase.verifyFalse(any(isgraphics(findall(0, "Type", "figure"))));
            testCase.verifyTrue(isfile(fullfile(result.artifact.run_directory, "analysis_tables.mat")));
        end
    end

    methods (Static, Access=private)
        function root = projectRoot()
            root = fileparts(fileparts(fileparts(mfilename("fullpath"))));
        end

        function aggregate = classificationFixture(ratios)
            n = numel(ratios);
            ids = "case" + string((1:n)).';
            trajectory = repmat("circle", n, 1);
            if n >= 4
                trajectory(ceil(n/2):end) = "lissajous_1_2";
            end
            rmseZoh = ones(n, 1);
            ratios = ratios(:);
            aggregate = table(ids, trajectory, 1.0 * ones(n, 1), ...
                (0.1 * (0:n-1)).', 0.02 * ones(n, 1), 0.1 * ones(n, 1), ...
                0.005 * ones(n, 1), 1.0 * ones(n, 1), 2 * ones(n, 1), ...
                zeros(n, 1), ones(n, 1), zeros(n, 1), 0.1 * ones(n, 1), ...
                0.1 * ones(n, 1), 0.1 * ones(n, 1), 0.02 * ones(n, 1), ...
                rmseZoh, ratios, rmseZoh, ratios, ones(n, 1), ratios, ratios, ...
                (1 - ratios) * 100, repmat("success", n, 1), ...
                'VariableNames', {'case_id','trajectory','omega_rad_s','delay_s', ...
                'sample_period_s','time_constant_s','fixed_step_s','duration_s', ...
                'warmup_cycles','evaluation_start_s','evaluation_end_s','omega_delay', ...
                'mean_packet_age_s','omega_mean_packet_age','omega_time_constant', ...
                'omega_sample_period','rmse_zoh_m','rmse_cv_m','nrmse_zoh','nrmse_cv', ...
                'max_error_zoh_m','max_error_cv_m','performance_ratio','improvement_percent','status'});
        end

        function input = selectionInput(classification)
            input = struct();
            input.cases = cell(height(classification), 1);
            for index = 1:height(classification)
                input.cases{index} = struct("case_id", classification.case_id(index), ...
                    "config", struct(), "trajectory", struct("acceleration_mps2", [0, 0; 1, 1], ...
                    "time_s", [0; 1]), "evaluation", struct("mask", [true; true]));
            end
        end

        function file = writeFixture(testCase, variant)
            data = issue9AnalysisTest.fixtureData();
            switch variant
                case "missing-metadata"
                    data = rmfield(data, "metadata");
                case "failed-status"
                    data.run_status = "failed";
                case "duplicate-case-id"
                    data.aggregate.case_id(2) = data.aggregate.case_id(1);
                case "nan-metric"
                    data.aggregate.rmse_zoh_m(1) = NaN;
                case "aggregate-mismatch"
                    data.aggregate.performance_ratio(1) = 0.25;
                case "valid"
                otherwise
                    error("teleopDelay:TestFixtureInvalid", "Unknown fixture variant.");
            end
            file = string(tempname) + ".mat";
            testCase.addTeardown(@() delete_if_exists(file));
            save(file, '-struct', 'data', '-v7');
        end

        function data = fixtureData()
            n = 40;
            delays = [0, 0.10, 0.20, 0.40, 0.50];
            omegas = [0.5, 1.0, 2.0, 4.0];
            caseIds = strings(n, 1);
            trajectories = strings(n, 1);
            delayValues = zeros(n, 1);
            omegaValues = zeros(n, 1);
            cases = cell(n, 1);
            trajectoryNames = ["circle", "lissajous_1_2"];
            rowIndex = 0;
            for trajectoryIndex = 1:2
                for delayIndex = 1:numel(delays)
                    for omegaIndex = 1:numel(omegas)
                        rowIndex = rowIndex + 1;
                        caseIds(rowIndex) = "case" + string(rowIndex);
                        trajectories(rowIndex) = trajectoryNames(trajectoryIndex);
                        delayValues(rowIndex) = delays(delayIndex);
                        omegaValues(rowIndex) = omegas(omegaIndex);
                        cases{rowIndex} = issue9AnalysisTest.fixtureCase(caseIds(rowIndex), ...
                            trajectories(rowIndex), omegaValues(rowIndex), delayValues(rowIndex));
                    end
                end
            end
            ratios = 0.5 + (0:n-1).' / 1000;
            aggregate = issue9AnalysisTest.classificationFixture(ratios);
            aggregate.case_id = caseIds;
            aggregate.trajectory = trajectories;
            aggregate.delay_s = delayValues;
            aggregate.omega_rad_s = omegaValues;
            aggregate.omega_delay = omegaValues .* delayValues;
            aggregate.omega_mean_packet_age = omegaValues .* (delayValues + 0.01);
            aggregate.mean_packet_age_s = delayValues + 0.01;
            aggregate.omega_time_constant = omegaValues * 0.1;
            aggregate.omega_sample_period = omegaValues * 0.02;
            for index = 1:n
                cases{index}.evaluation.performance_ratio = aggregate.performance_ratio(index);
                cases{index}.evaluation.improvement_percent = aggregate.improvement_percent(index);
                cases{index}.evaluation.omega_delay = aggregate.omega_delay(index);
                cases{index}.evaluation.mean_packet_age_s = aggregate.mean_packet_age_s(index);
                cases{index}.evaluation.omega_mean_packet_age = aggregate.omega_mean_packet_age(index);
                cases{index}.evaluation.omega_time_constant = aggregate.omega_time_constant(index);
                cases{index}.evaluation.omega_sample_period = aggregate.omega_sample_period(index);
                cases{index}.evaluation.rmse_cv_m = aggregate.rmse_cv_m(index);
                cases{index}.evaluation.nrmse_cv = aggregate.nrmse_cv(index);
                cases{index}.evaluation.max_error_cv_m = aggregate.max_error_cv_m(index);
            end
            manifest = struct("case_count", 40);
            metadata = struct("run_status", "complete", "success_case_count", 40, ...
                "failed_case_count", 0, "total_case_count", 40, "git_commit_sha", "fixture", ...
                "matlab_version", string(version), "run_id", "fixture", "experiment_id", "fixture", ...
                "manifest_schema_version", "issue8.standard.v1");
            data = struct("manifest", manifest, "aggregate", aggregate, "metadata", metadata, ...
                "cases", {cases}, "run_status", "complete", "experiment_id", "fixture", "run_id", "fixture");
        end

        function caseResult = fixtureCase(caseId, trajectory, omega, delay)
            time = [0; 0.1; 0.2];
            position = [0, 0; 1, 0; 0, 1];
            simulation = struct("time_s", time, "zoh_command_xy_m", position, ...
                "cv_command_xy_m", position, "zoh_position_xy_m", position, ...
                "cv_position_xy_m", position, "reference_position_xy_m", position, ...
                "packet_timestamp_s", zeros(3, 1), "packet_age_s", 0.01 * ones(3, 1), ...
                "packet_valid", true(3, 1), "solver", "ode4", "fixed_step_s", 0.005);
            trajectoryResult = struct("type", trajectory, "time_s", time, ...
                "position_m", position, "velocity_mps", position, "acceleration_mps2", position);
            evaluation = struct("mask", true(3, 1), "rmse_zoh_m", 1, "rmse_cv_m", 0.5, ...
                "nrmse_zoh", 1, "nrmse_cv", 0.5, "max_error_zoh_m", 1, ...
                "max_error_cv_m", 0.5, "performance_ratio", 0.5, "improvement_percent", 50, ...
                "mean_packet_age_s", delay + 0.01, "omega_delay", omega * delay, ...
                "omega_mean_packet_age", omega * (delay + 0.01), "omega_time_constant", omega * 0.1, ...
                "omega_sample_period", omega * 0.02);
            config = struct("trajectory", struct("type", trajectory, "amplitude", 1, "omega", omega), ...
                "evaluation", struct("total_cycles", 10, "warmup_cycles", 2), ...
                "communication", struct("delay", delay, "sample_period", 0.02), ...
                "plant", struct("time_constant", 0.1), "simulation", struct("dt", 0.005, ...
                "fixed_step", 0.005, "duration", 1.0, "solver", "ode4"));
            caseResult = struct("case_id", caseId, "status", "success", "config", config, ...
                "trajectory", trajectoryResult, "simulation", simulation, "evaluation", evaluation);
        end
    end
end

function delete_if_exists(file)
if isfile(file)
    delete(file);
end
end
