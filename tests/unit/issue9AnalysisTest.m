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

        function testManifestCasesRequired(testCase)
            file = issue9AnalysisTest.writeFixture(testCase, "manifest-cases-missing");
            testCase.verifyError(@() teleopdelay.analysis.load_input(file), ...
                "teleopDelay:AnalysisInputSchemaMismatch");
        end

        function testManifestAggregateCaseIdMismatchRejected(testCase)
            file = issue9AnalysisTest.writeFixture(testCase, "manifest-case-id-mismatch");
            testCase.verifyError(@() teleopdelay.analysis.load_input(file), ...
                "teleopDelay:AnalysisInputDuplicateCase");
        end

        function testShiftedTimeRejected(testCase)
            file = issue9AnalysisTest.writeFixture(testCase, "shifted-time");
            testCase.verifyError(@() teleopdelay.analysis.load_input(file), ...
                "teleopDelay:AnalysisInputSchemaMismatch");
        end

        function testNonmonotonicTimeRejected(testCase)
            file = issue9AnalysisTest.writeFixture(testCase, "nonmonotonic-time");
            testCase.verifyError(@() teleopdelay.analysis.load_input(file), ...
                "teleopDelay:AnalysisInputSchemaMismatch");
        end

        function testNanAccelerationRejected(testCase)
            file = issue9AnalysisTest.writeFixture(testCase, "nan-acceleration");
            testCase.verifyError(@() teleopdelay.analysis.load_input(file), ...
                "teleopDelay:AnalysisInputSchemaMismatch");
        end

        function testPacketValidTypeRejected(testCase)
            file = issue9AnalysisTest.writeFixture(testCase, "double-packet-valid");
            testCase.verifyError(@() teleopdelay.analysis.load_input(file), ...
                "teleopDelay:AnalysisInputSchemaMismatch");
        end

        function testInvalidEvaluationPacketRejected(testCase)
            file = issue9AnalysisTest.writeFixture(testCase, "invalid-evaluation-packet");
            testCase.verifyError(@() teleopdelay.analysis.load_input(file), ...
                "teleopDelay:AnalysisInputSchemaMismatch");
        end

        function testRecomputedMetricContradictionRejected(testCase)
            file = issue9AnalysisTest.writeFixture(testCase, "metric-contradiction");
            testCase.verifyError(@() teleopdelay.analysis.load_input(file), ...
                "teleopDelay:AnalysisInputSchemaMismatch");
        end

        function testDimensionlessCaseIdJoinIsPermutationInvariant(testCase)
            data = issue9AnalysisTest.fixtureData();
            input = teleopdelay.analysis.load_input(issue9AnalysisTest.saveData(testCase, data));
            classification = teleopdelay.analysis.classify(input.aggregate, 1e-12);
            theory = teleopdelay.analysis.theory();
            diagnosticsFirst = teleopdelay.analysis.dimensionless(input.aggregate, classification, theory);
            permutation = [17:40, 1:16];
            diagnosticsSecond = teleopdelay.analysis.dimensionless(input.aggregate, ...
                classification(permutation, :), theory);
            first = sortrows(diagnosticsFirst, "case_id");
            second = sortrows(diagnosticsSecond, "case_id");
            testCase.verifyEqual(first(:, {'case_id', 'classification', 'q_delay', 'q_age', ...
                'q1_age', 'q2_age', 'performance_ratio'}), ...
                second(:, {'case_id', 'classification', 'q_delay', 'q_age', ...
                'q1_age', 'q2_age', 'performance_ratio'}));
        end

        function testAnalysisTablesAreCaseIdPermutationInvariant(testCase)
            data = issue9AnalysisTest.fixtureData();
            input = teleopdelay.analysis.load_input(issue9AnalysisTest.saveData(testCase, data));
            classification = teleopdelay.analysis.classify(input.aggregate, 1e-12);
            config = teleopdelay.analysis.default_config();
            theory = teleopdelay.analysis.theory();
            firstRepresentatives = teleopdelay.analysis.select_representatives(input, classification, config);
            firstBoundaries = teleopdelay.analysis.detect_boundaries(classification, theory, config);
            permutation = [17:40, 1:16];
            permuted = classification(permutation, :);
            secondRepresentatives = teleopdelay.analysis.select_representatives(input, permuted, config);
            secondBoundaries = teleopdelay.analysis.detect_boundaries(permuted, theory, config);
            firstRepresentatives = sortrows(firstRepresentatives, {'trajectory', 'role'});
            secondRepresentatives = sortrows(secondRepresentatives, {'trajectory', 'role'});
            firstBoundaries = sortrows(firstBoundaries, {'trajectory', 'varied_axis', ...
                'fixed_axis_value', 'lower_case_id', 'upper_case_id'});
            secondBoundaries = sortrows(secondBoundaries, {'trajectory', 'varied_axis', ...
                'fixed_axis_value', 'lower_case_id', 'upper_case_id'});
            testCase.verifyEqual(firstRepresentatives.case_id, secondRepresentatives.case_id);
            testCase.verifyEqual(firstRepresentatives.selection_reason, secondRepresentatives.selection_reason);
            testCase.verifyEqual(firstBoundaries, secondBoundaries);
        end

        function testDimensionlessFigureSourceCaseIdsMatchClassification(testCase)
            data = issue9AnalysisTest.fixtureData();
            input = teleopdelay.analysis.load_input(issue9AnalysisTest.saveData(testCase, data));
            classification = teleopdelay.analysis.classify(input.aggregate, 1e-12);
            diagnostics = teleopdelay.analysis.dimensionless(input.aggregate, classification, ...
                teleopdelay.analysis.theory());
            figuresDirectory = string(tempname);
            mkdir(figuresDirectory);
            testCase.addTeardown(@() rmdir(figuresDirectory, "s"));
            entry = teleopdelay.analysis.render_dimensionless(diagnostics, ...
                teleopdelay.analysis.theory(), "omega_delay", "figure_test_dimensionless", ...
                figuresDirectory, teleopdelay.analysis.default_config());
            sourceIds = sort(string(strsplit(entry.case_ids, "|"))).';
            classificationIds = sort(string(classification.case_id));
            testCase.verifyEqual(sourceIds, classificationIds);
            testCase.verifyTrue(isfile(fullfile(figuresDirectory, entry.filename_png)));
            testCase.verifyTrue(isfile(fullfile(figuresDirectory, entry.filename_pdf)));
            ageEntry = teleopdelay.analysis.render_dimensionless(diagnostics, ...
                teleopdelay.analysis.theory(), "omega_mean_packet_age", ...
                "figure_test_dimensionless_age", figuresDirectory, ...
                teleopdelay.analysis.default_config());
            ageSourceIds = sort(string(strsplit(ageEntry.case_ids, "|"))).';
            testCase.verifyEqual(ageSourceIds, classificationIds);
            testCase.verifyTrue(isfile(fullfile(figuresDirectory, ageEntry.filename_png)));
            testCase.verifyTrue(isfile(fullfile(figuresDirectory, ageEntry.filename_pdf)));
        end

        function testEventPercentileConfigChangesEvents(testCase)
            acceleration = [1; 2; 3; 4; 5];
            [events75, threshold75] = teleopdelay.analysis.event_acceleration_mask(acceleration, 75);
            [events40, threshold40] = teleopdelay.analysis.event_acceleration_mask(acceleration, 40);
            testCase.verifyNotEqual(threshold75, threshold40);
            testCase.verifyNotEqual(events75, events40);
        end

        function testInvalidEventPercentileRejected(testCase)
            config = teleopdelay.analysis.default_config();
            config.event_acceleration_percentile = 100.1;
            testCase.verifyError(@() teleopdelay.analysis.validate_config(config), ...
                "teleopDelay:AnalysisConfigInvalid");
        end

        function testRelativeDeltaScaleAwareContract(testCase)
            tableValue = issue9AnalysisTest.convergenceMetricFixtureTable(0.1, 0.101);
            testCase.verifyEqual(tableValue.relative_delta_rmse_zoh(1), 0.01, AbsTol=1e-12);
            zeroBase = issue9AnalysisTest.convergenceMetricFixtureTable(0, 1e-6);
            testCase.verifyTrue(isfinite(zeroBase.relative_delta_rmse_zoh(1)));
            negative = issue9AnalysisTest.convergenceMetricFixtureTable(0.1, 0.099);
            testCase.verifyLessThan(negative.delta_rmse_zoh_m(1), 0);
            testCase.verifyGreaterThanOrEqual(negative.relative_delta_rmse_zoh(1), 0);
        end

        function testEmptyConvergenceArtifactIsNotAvailable(testCase)
            input = teleopdelay.analysis.load_input(issue9AnalysisTest.saveData(testCase, ...
                issue9AnalysisTest.convergenceFixtureData()));
            config = teleopdelay.analysis.default_config();
            classification = teleopdelay.analysis.classify(input.aggregate, ...
                teleopdelay.analysis.machine_tolerance(input.aggregate.performance_ratio));
            representatives = teleopdelay.analysis.select_representatives(input, classification, config);
            data = issue9AnalysisTest.convergenceData(input, representatives, ...
                teleopdelay.analysis.convergence_table());
            file = issue9AnalysisTest.saveConvergenceData(testCase, data);
            testCase.verifyError(@() teleopdelay.analysis.load_convergence(input, file, ...
                "", config, true, representatives), "teleopDelay:AnalysisConvergenceSchemaMismatch");
            testCase.verifyError(@() teleopdelay.analysis.load_convergence(input, "", ...
                "", config, true, representatives), "teleopDelay:AnalysisConvergenceMissing");
        end

        function testInvalidConvergenceCandidatesAreDiagnosed(testCase)
            input = teleopdelay.analysis.load_input(issue9AnalysisTest.saveData(testCase, ...
                issue9AnalysisTest.convergenceFixtureData()));
            config = teleopdelay.analysis.default_config();
            classification = teleopdelay.analysis.classify(input.aggregate, ...
                teleopdelay.analysis.machine_tolerance(input.aggregate.performance_ratio));
            representatives = teleopdelay.analysis.select_representatives(input, classification, config);
            root = string(tempname);
            mkdir(root);
            testCase.addTeardown(@() rmdir(root, "s"));
            variants = ["source-sha-mismatch", "refined-step-mismatch", "solver-mismatch", ...
                "duplicate-case-id", "nonvalidated", "empty-table"];
            for index = 1:numel(variants)
                data = issue9AnalysisTest.convergenceData(input, representatives, ...
                    issue9AnalysisTest.convergenceFixtureTable(input, representatives, 0.001));
                data = issue9AnalysisTest.mutateConvergenceData(data, variants(index));
                issue9AnalysisTest.writeConvergenceDirectory(data, root, "candidate" + string(index));
            end
            result = teleopdelay.analysis.load_convergence(input, "", root, config, false, representatives);
            testCase.verifyFalse(result.available);
            testCase.verifyEqual(height(result.diagnostics), numel(variants));
            testCase.verifyTrue(all(~result.diagnostics.valid));
            testCase.verifyTrue(all(strlength(result.diagnostics.reason) > 0));
        end

        function testDifferentValidConvergenceCandidatesAreAmbiguous(testCase)
            input = teleopdelay.analysis.load_input(issue9AnalysisTest.saveData(testCase, ...
                issue9AnalysisTest.convergenceFixtureData()));
            config = teleopdelay.analysis.default_config();
            classification = teleopdelay.analysis.classify(input.aggregate, ...
                teleopdelay.analysis.machine_tolerance(input.aggregate.performance_ratio));
            representatives = teleopdelay.analysis.select_representatives(input, classification, config);
            root = string(tempname);
            mkdir(root);
            testCase.addTeardown(@() rmdir(root, "s"));
            first = issue9AnalysisTest.convergenceData(input, representatives, ...
                issue9AnalysisTest.convergenceFixtureTable(input, representatives, 0.001));
            second = issue9AnalysisTest.convergenceData(input, representatives, ...
                issue9AnalysisTest.convergenceFixtureTable(input, representatives, 0.002));
            issue9AnalysisTest.writeConvergenceDirectory(first, root, "a");
            issue9AnalysisTest.writeConvergenceDirectory(second, root, "b");
            testCase.verifyError(@() teleopdelay.analysis.load_convergence(input, "", root, config, false, representatives), ...
                "teleopDelay:AnalysisConvergenceAmbiguous");
        end

        function testSameSemanticConvergenceCandidatesUseDeterministicSelection(testCase)
            input = teleopdelay.analysis.load_input(issue9AnalysisTest.saveData(testCase, ...
                issue9AnalysisTest.convergenceFixtureData()));
            config = teleopdelay.analysis.default_config();
            classification = teleopdelay.analysis.classify(input.aggregate, ...
                teleopdelay.analysis.machine_tolerance(input.aggregate.performance_ratio));
            representatives = teleopdelay.analysis.select_representatives(input, classification, config);
            root = string(tempname);
            mkdir(root);
            testCase.addTeardown(@() rmdir(root, "s"));
            data = issue9AnalysisTest.convergenceData(input, representatives, ...
                issue9AnalysisTest.convergenceFixtureTable(input, representatives, 0.001));
            issue9AnalysisTest.writeConvergenceDirectory(data, root, "b");
            issue9AnalysisTest.writeConvergenceDirectory(data, root, "a");
            result = teleopdelay.analysis.load_convergence(input, "", root, config, false, representatives);
            testCase.verifyTrue(result.available);
            testCase.verifyEqual(result.source, "saved-convergence-artifact");
            testCase.verifyEqual(result.diagnostics.selected(1), true);
            testCase.verifyEqual(sum(result.diagnostics.selected), 1);
        end

        function testRepresentativeConvergenceArtifactIsAccepted(testCase)
            [input, config, representatives, data] = issue9AnalysisTest.convergenceArtifactFixture(testCase);
            file = issue9AnalysisTest.saveConvergenceData(testCase, data);
            result = teleopdelay.analysis.load_convergence(input, file, "", config, true, representatives);
            plan = teleopdelay.analysis.convergence_plan(input, representatives, config);
            testCase.verifyTrue(result.available);
            testCase.verifyEqual(height(result.table), 5);
            testCase.verifyEqual(sort(string(result.table.case_id)), sort(string(plan.case_ids)));
        end

        function testOneCaseConvergenceArtifactRejected(testCase)
            [input, config, representatives, data] = issue9AnalysisTest.convergenceArtifactFixture(testCase);
            data.convergence_artifact.table = data.convergence_artifact.table(1, :);
            data.convergence = data.convergence_artifact.table;
            file = issue9AnalysisTest.saveConvergenceData(testCase, data);
            testCase.verifyError(@() teleopdelay.analysis.load_convergence(input, file, ...
                "", config, true, representatives), "teleopDelay:AnalysisConvergenceSchemaMismatch");
        end

        function testNonRepresentativeConvergenceCaseRejected(testCase)
            [input, config, representatives, data] = issue9AnalysisTest.convergenceArtifactFixture(testCase);
            data.convergence_artifact.table.case_id(1) = "case3";
            data.convergence = data.convergence_artifact.table;
            file = issue9AnalysisTest.saveConvergenceData(testCase, data);
            testCase.verifyError(@() teleopdelay.analysis.load_convergence(input, file, ...
                "", config, true, representatives), "teleopDelay:AnalysisConvergenceSchemaMismatch");
        end

        function testRoleMappingMismatchRejected(testCase)
            [input, config, representatives, data] = issue9AnalysisTest.convergenceArtifactFixture(testCase);
            data.convergence_artifact.table.role_mapping(1) = "nearest_boundary";
            data.convergence = data.convergence_artifact.table;
            file = issue9AnalysisTest.saveConvergenceData(testCase, data);
            testCase.verifyError(@() teleopdelay.analysis.load_convergence(input, file, ...
                "", config, true, representatives), "teleopDelay:AnalysisConvergenceSchemaMismatch");
        end

        function testConvergenceConditionMismatchRejected(testCase)
            [input, config, representatives, data] = issue9AnalysisTest.convergenceArtifactFixture(testCase);
            data.convergence_artifact.table.omega_rad_s(1) = ...
                data.convergence_artifact.table.omega_rad_s(1) + 0.1;
            data.convergence = data.convergence_artifact.table;
            file = issue9AnalysisTest.saveConvergenceData(testCase, data);
            testCase.verifyError(@() teleopdelay.analysis.load_convergence(input, file, ...
                "", config, true, representatives), "teleopDelay:AnalysisConvergenceSchemaMismatch");
        end

        function testConvergenceBasePerformanceRatioMismatchRejected(testCase)
            [input, config, representatives, data] = issue9AnalysisTest.convergenceArtifactFixture(testCase);
            data.convergence_artifact.table.base_performance_ratio(1) = ...
                data.convergence_artifact.table.base_performance_ratio(1) + 0.01;
            data.convergence = data.convergence_artifact.table;
            file = issue9AnalysisTest.saveConvergenceData(testCase, data);
            testCase.verifyError(@() teleopdelay.analysis.load_convergence(input, file, ...
                "", config, true, representatives), "teleopDelay:AnalysisConvergenceSchemaMismatch");
        end

        function testConvergenceBaseRmseMismatchRejected(testCase)
            [input, config, representatives, data] = issue9AnalysisTest.convergenceArtifactFixture(testCase);
            data.convergence_artifact.table.base_rmse_zoh_m(1) = ...
                data.convergence_artifact.table.base_rmse_zoh_m(1) + 0.01;
            data.convergence = data.convergence_artifact.table;
            file = issue9AnalysisTest.saveConvergenceData(testCase, data);
            testCase.verifyError(@() teleopdelay.analysis.load_convergence(input, file, ...
                "", config, true, representatives), "teleopDelay:AnalysisConvergenceSchemaMismatch");
        end

        function testConvergenceBaseMaxErrorMismatchRejected(testCase)
            [input, config, representatives, data] = issue9AnalysisTest.convergenceArtifactFixture(testCase);
            data.convergence_artifact.table.base_max_error_cv_m(1) = ...
                data.convergence_artifact.table.base_max_error_cv_m(1) + 0.01;
            data.convergence = data.convergence_artifact.table;
            file = issue9AnalysisTest.saveConvergenceData(testCase, data);
            testCase.verifyError(@() teleopdelay.analysis.load_convergence(input, file, ...
                "", config, true, representatives), "teleopDelay:AnalysisConvergenceSchemaMismatch");
        end

        function testConvergenceMetadataMismatchRejected(testCase)
            [input, config, representatives, data] = issue9AnalysisTest.convergenceArtifactFixture(testCase);
            data.convergence_artifact.metadata.solver = "ode45";
            file = issue9AnalysisTest.saveConvergenceData(testCase, data);
            testCase.verifyError(@() teleopdelay.analysis.load_convergence(input, file, ...
                "", config, true, representatives), "teleopDelay:AnalysisConvergenceSchemaMismatch");
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
            issue9AnalysisTest.verifyArtifactManifest(testCase, result.artifact.run_directory);
        end

        function testSavedFigureDeterminism(testCase)
            file = issue9AnalysisTest.writeFixture(testCase, "valid");
            firstRoot = string(tempname);
            secondRoot = string(tempname);
            mkdir(firstRoot);
            mkdir(secondRoot);
            testCase.addTeardown(@() rmdir(firstRoot, "s"));
            testCase.addTeardown(@() rmdir(secondRoot, "s"));
            first = run_issue9_analysis("InputMat", file, "Mode", "render-only", ...
                "OutputRoot", firstRoot, "SaveResults", true);
            second = run_issue9_analysis("InputMat", file, "Mode", "render-only", ...
                "OutputRoot", secondRoot, "SaveResults", true);
            firstManifest = sortrows(readtable(fullfile(first.artifact.run_directory, ...
                "figure_manifest.csv")), "figure_id");
            secondManifest = sortrows(readtable(fullfile(second.artifact.run_directory, ...
                "figure_manifest.csv")), "figure_id");
            testCase.verifyEqual(firstManifest(:, {'figure_id', 'trajectory', 'case_ids', ...
                'caption', 'axes_contract'}), secondManifest(:, {'figure_id', 'trajectory', ...
                'case_ids', 'caption', 'axes_contract'}));
            testCase.verifyFalse(any(isgraphics(findall(0, "Type", "figure"))));
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
                case "manifest-cases-missing"
                    data.manifest = rmfield(data.manifest, "cases");
                case "manifest-case-id-mismatch"
                    data.manifest.cases(1).case_id = "not-the-aggregate-case";
                case "shifted-time"
                    data.cases{1}.trajectory.time_s(2) = data.cases{1}.trajectory.time_s(2) + 0.001;
                case "nonmonotonic-time"
                    data.cases{1}.simulation.time_s(2) = data.cases{1}.simulation.time_s(1);
                case "nan-acceleration"
                    data.cases{1}.trajectory.acceleration_mps2(2, 1) = NaN;
                case "double-packet-valid"
                    data.cases{1}.simulation.packet_valid = double(data.cases{1}.simulation.packet_valid);
                case "invalid-evaluation-packet"
                    data.cases{1}.simulation.packet_valid(1) = false;
                case "metric-contradiction"
                    data.aggregate.performance_ratio(1) = 0.25;
                    data.aggregate.improvement_percent(1) = 75;
                    data.cases{1}.evaluation.performance_ratio = 0.25;
                    data.cases{1}.evaluation.improvement_percent = 75;
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
            aggregate.duration_s = 0.2 * ones(n, 1);
            aggregate.evaluation_start_s = zeros(n, 1);
            aggregate.evaluation_end_s = 0.2 * ones(n, 1);
            for index = 1:n
                cases{index}.simulation.cv_position_xy_m = aggregate.performance_ratio(index) * ...
                    cases{index}.simulation.zoh_position_xy_m;
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
            manifestCases = repmat(issue9AnalysisTest.fixtureManifestCase(cases{1}), n, 1);
            for index = 1:n
                manifestCases(index) = issue9AnalysisTest.fixtureManifestCase(cases{index});
            end
            manifest = struct("schema_version", "issue8.standard.v1", ...
                "experiment_id", "fixture", "case_count", 40, ...
                "condition_fields", ["trajectory", "omega_rad_s", "delay_s"], ...
                "cases", manifestCases);
            metadata = struct("run_status", "complete", "success_case_count", 40, ...
                "failed_case_count", 0, "total_case_count", 40, "git_commit_sha", "fixture", ...
                "matlab_version", string(version), "run_id", "fixture", "experiment_id", "fixture", ...
                "manifest_schema_version", "issue8.standard.v1");
            data = struct("manifest", manifest, "aggregate", aggregate, "metadata", metadata, ...
                "cases", {cases}, "run_status", "complete", "experiment_id", "fixture", "run_id", "fixture");
        end

        function file = saveData(testCase, data)
            file = string(tempname) + ".mat";
            testCase.addTeardown(@() delete_if_exists(file));
            save(file, '-struct', 'data', '-v7');
        end

        function entry = fixtureManifestCase(caseResult)
            config = caseResult.config;
            entry = struct("case_id", string(caseResult.case_id), ...
                "canonical_key", "fixture|" + string(caseResult.case_id), ...
                "trajectory", string(config.trajectory.type), ...
                "amplitude_m", double(config.trajectory.amplitude), ...
                "omega_rad_s", double(config.trajectory.omega), ...
                "delay_s", double(config.communication.delay), ...
                "sample_period_s", double(config.communication.sample_period), ...
                "time_constant_s", double(config.plant.time_constant), ...
                "dt_s", double(config.simulation.dt), ...
                "fixed_step_s", double(config.simulation.fixed_step), ...
                "total_cycles", double(config.evaluation.total_cycles), ...
                "warmup_cycles", double(config.evaluation.warmup_cycles), ...
                "solver", string(config.simulation.solver), ...
                "nominal_duration_s", double(config.simulation.duration), ...
                "expected_duration_s", double(config.simulation.duration), ...
                "duration_s", double(config.simulation.duration));
        end

        function [input, config, representatives, data] = convergenceArtifactFixture(testCase)
            input = teleopdelay.analysis.load_input(issue9AnalysisTest.saveData(testCase, ...
                issue9AnalysisTest.convergenceFixtureData()));
            config = teleopdelay.analysis.default_config();
            classification = teleopdelay.analysis.classify(input.aggregate, ...
                teleopdelay.analysis.machine_tolerance(input.aggregate.performance_ratio));
            representatives = teleopdelay.analysis.select_representatives(input, classification, config);
            tableValue = issue9AnalysisTest.convergenceFixtureTable(input, representatives, 0.001);
            data = issue9AnalysisTest.convergenceData(input, representatives, tableValue);
        end

        function data = convergenceFixtureData()
            data = issue9AnalysisTest.fixtureData();
            ratios = [0.500; 0.501; 0.502; 0.503; 0.504; 0.505; 0.506; 0.507; ...
                0.508; 0.509; 0.510; 0.511; 0.512; 0.513; 0.514; 0.515; ...
                0.516; 0.517; 0.518; 1.200; 0.520; 0.521; 0.522; 0.523; ...
                0.524; 0.525; 0.526; 0.527; 0.528; 0.529; 0.530; 0.531; ...
                0.532; 0.533; 0.534; 0.535; 0.536; 0.537; 0.990; 1.300].';
            for index = 1:numel(ratios)
                zoh = data.cases{index}.simulation.zoh_position_xy_m - ...
                    data.cases{index}.simulation.reference_position_xy_m;
                cv = ratios(index) * data.cases{index}.simulation.zoh_position_xy_m;
                data.cases{index}.simulation.cv_position_xy_m = cv;
                cvError = cv - data.cases{index}.simulation.reference_position_xy_m;
                rmseZoh = sqrt(mean(sum(zoh.^2, 2)));
                rmseCv = sqrt(mean(sum(cvError.^2, 2)));
                maxZoh = max(vecnorm(zoh, 2, 2));
                maxCv = max(vecnorm(cvError, 2, 2));
                data.aggregate.rmse_cv_m(index) = rmseCv;
                data.aggregate.nrmse_cv(index) = rmseCv;
                data.aggregate.max_error_cv_m(index) = maxCv;
                data.aggregate.performance_ratio(index) = rmseCv / rmseZoh;
                data.aggregate.improvement_percent(index) = (1 - rmseCv / rmseZoh) * 100;
                data.cases{index}.evaluation.rmse_cv_m = rmseCv;
                data.cases{index}.evaluation.nrmse_cv = rmseCv;
                data.cases{index}.evaluation.max_error_cv_m = maxCv;
                data.cases{index}.evaluation.performance_ratio = rmseCv / rmseZoh;
                data.cases{index}.evaluation.improvement_percent = ...
                    (1 - rmseCv / rmseZoh) * 100;
            end
        end

        function tableValue = convergenceMetricFixtureTable(base, refined)
            delta = refined - base;
            denominator = max(abs(base), 64 * eps(max([1, abs(base), abs(refined)])));
            relative = abs(delta) / denominator;
            rows = {"best", "best", "circle", "case1", 1, 0, 0.005, 0.0025, 0.02, ...
                base, refined, base, refined, 1, 1, delta, delta, 0, relative, relative, 0, ...
                base, refined, base, refined, delta, delta, relative, relative, 8, true, "validated"};
            tableValue = teleopdelay.analysis.convergence_table(rows);
        end

        function tableValue = convergenceFixtureTable(input, representatives, delta)
            config = teleopdelay.analysis.default_config();
            plan = teleopdelay.analysis.convergence_plan(input, representatives, config);
            rows = cell(plan.case_count, 32);
            for index = 1:plan.case_count
                expected = plan.table(index, :);
                baseG = expected.base_performance_ratio;
                refinedG = baseG + delta;
                baseZoh = expected.base_rmse_zoh_m;
                baseCv = expected.base_rmse_cv_m;
                baseMaxZoh = expected.base_max_error_zoh_m;
                baseMaxCv = expected.base_max_error_cv_m;
                refinedZoh = baseZoh + delta;
                refinedCv = baseCv + delta;
                refinedMaxZoh = baseMaxZoh + delta;
                refinedMaxCv = baseMaxCv + delta;
                relativeZoh = abs(refinedZoh - baseZoh) / max(abs(baseZoh), ...
                    64 * eps(max([1, abs(baseZoh), abs(refinedZoh)])));
                relativeCv = abs(refinedCv - baseCv) / max(abs(baseCv), ...
                    64 * eps(max([1, abs(baseCv), abs(refinedCv)])));
                relativeG = abs(refinedG - baseG) / max(abs(baseG), ...
                    64 * eps(max([1, abs(baseG), abs(refinedG)])));
                relativeMaxZoh = abs(refinedMaxZoh - baseMaxZoh) / max(abs(baseMaxZoh), ...
                    64 * eps(max([1, abs(baseMaxZoh), abs(refinedMaxZoh)])));
                relativeMaxCv = abs(refinedMaxCv - baseMaxCv) / max(abs(baseMaxCv), ...
                    64 * eps(max([1, abs(baseMaxCv), abs(refinedMaxCv)])));
                rows(index, :) = {expected.primary_role, expected.role_mapping, ...
                    expected.trajectory, expected.case_id, expected.omega_rad_s, ...
                    expected.delay_s, 0.005, 0.0025, 0.02, baseZoh, refinedZoh, ...
                    baseCv, refinedCv, baseG, refinedG, refinedZoh - baseZoh, ...
                    refinedCv - baseCv, refinedG - baseG, relativeZoh, relativeCv, ...
                    relativeG, baseMaxZoh, refinedMaxZoh, baseMaxCv, refinedMaxCv, ...
                    refinedMaxZoh - baseMaxZoh, refinedMaxCv - baseMaxCv, ...
                    relativeMaxZoh, relativeMaxCv, 8, true, "validated"};
            end
            tableValue = teleopdelay.analysis.convergence_table(rows);
        end

        function verifyArtifactManifest(testCase, directory)
            sidecar = readtable(fullfile(directory, "artifact_manifest.csv"), ...
                "Delimiter", ",", "VariableNamingRule", "preserve");
            relative = string(sidecar.relative_path);
            testCase.verifyFalse(any(relative == "artifact_manifest.csv"));
            matIndex = find(relative == "analysis_tables.mat", 1);
            testCase.verifyNotEmpty(matIndex);
            matPath = fullfile(directory, "analysis_tables.mat");
            testCase.verifyEqual(string(sidecar.sha256(matIndex)), ...
                string(teleopdelay.experiment.sha256_file(matPath)));
            metadataData = load(matPath, "metadata");
            outputFiles = metadataData.metadata.output_files;
            testCase.verifyFalse(any(string(outputFiles.relative_path) == "analysis_tables.mat"));
            for index = 1:height(sidecar)
                filePath = fullfile(directory, char(relative(index)));
                fileInfo = dir(filePath);
                testCase.verifyTrue(isfile(filePath));
                testCase.verifyEqual(double(fileInfo.bytes), double(sidecar.size_bytes(index)));
                testCase.verifyEqual(string(sidecar.sha256(index)), ...
                    string(teleopdelay.experiment.sha256_file(filePath)));
            end
            for index = 1:height(outputFiles)
                filePath = fullfile(directory, char(string(outputFiles.relative_path(index))));
                fileInfo = dir(filePath);
                testCase.verifyTrue(isfile(filePath));
                testCase.verifyEqual(double(fileInfo.bytes), double(outputFiles.size_bytes(index)));
                testCase.verifyEqual(string(outputFiles.sha256(index)), ...
                    string(teleopdelay.experiment.sha256_file(filePath)));
            end
        end

        function data = convergenceData(input, ~, tableValue)
            config = teleopdelay.analysis.default_config();
            caseIds = string(tableValue.case_id);
            convergenceMetadata = struct( ...
                "analysis_schema_version", string(config.analysis_schema_version), ...
                "convergence_schema_version", string(config.convergence.schema_version), ...
                "source_mat_sha256", string(input.source_mat_sha256), ...
                "source_experiment_id", string(input.source_experiment_id), ...
                "solver", string(config.convergence.solver), ...
                "base_fixed_step_s", config.convergence.base_fixed_step_s, ...
                "refined_fixed_step_s", config.convergence.refined_fixed_step_s, ...
                "sample_period_s", config.convergence.sample_period_s, ...
                "alignment_ratio", 8, "alignment_valid", true, ...
                "convergence_case_ids", caseIds, ...
                "role_mapping", string(tableValue.role_mapping), ...
                "primary_roles", string(tableValue.role));
            metadata = struct("source_mat_sha256", string(input.source_mat_sha256), ...
                "analysis_schema_version", string(config.analysis_schema_version), ...
                "convergence_metadata", convergenceMetadata);
            data = struct( ...
                "analysis_schema_version", string(config.analysis_schema_version), ...
                "convergence_schema_version", string(config.convergence.schema_version), ...
                "metadata", metadata, "convergence_metadata", convergenceMetadata, ...
                "convergence", tableValue, ...
                "convergence_artifact", struct("available", true, "table", tableValue, ...
                "metadata", convergenceMetadata));
        end

        function file = saveConvergenceData(testCase, data)
            file = string(tempname) + ".mat";
            testCase.addTeardown(@() delete_if_exists(file));
            save(file, '-struct', 'data', '-v7');
        end

        function writeConvergenceDirectory(data, root, name)
            directory = fullfile(root, "analysis", "fixture", string(name), "run");
            mkdir(directory);
            save(fullfile(directory, "analysis_tables.mat"), '-struct', 'data', '-v7');
        end

        function data = mutateConvergenceData(data, variant)
            switch string(variant)
                case "source-sha-mismatch"
                    data.metadata.source_mat_sha256 = "0" + extractAfter(string(data.metadata.source_mat_sha256), 1);
                case "refined-step-mismatch"
                    data.convergence_metadata.refined_fixed_step_s = 0.005;
                case "solver-mismatch"
                    data.convergence_metadata.solver = "ode45";
                case "duplicate-case-id"
                    data.convergence_artifact.table = [data.convergence_artifact.table; ...
                        data.convergence_artifact.table];
                case "nonvalidated"
                    data.convergence_artifact.table.convergence_status(1) = "failed";
                case "empty-table"
                    data.convergence_artifact.table = teleopdelay.analysis.convergence_table();
            end
        end

        function caseResult = fixtureCase(caseId, trajectory, omega, delay)
            time = [0; 0.1; 0.2];
            position = [0, 0; 1, 0; 0, 1];
            reference = zeros(3, 2);
            zohPosition = ones(3, 2);
            zohPosition(:, 2) = 0;
            cvPosition = 0.5 * zohPosition;
            simulation = struct("time_s", time, "zoh_command_xy_m", position, ...
                "cv_command_xy_m", position, "zoh_position_xy_m", zohPosition, ...
                "cv_position_xy_m", cvPosition, "reference_position_xy_m", reference, ...
                "packet_timestamp_s", zeros(3, 1), "packet_age_s", (delay + 0.01) * ones(3, 1), ...
                "packet_valid", true(3, 1), "solver", "ode4", "fixed_step_s", 0.005);
            trajectoryResult = struct("type", trajectory, "time_s", time, ...
                "position_m", position, "velocity_mps", position, "acceleration_mps2", position);
            evaluation = struct("period_s", 2 * pi / omega, "total_cycles", 10, ...
                "warmup_cycles", 2, "sample_start_s", 0, "sample_end_s", 0.2, ...
                "sample_count", 3, "mask", true(3, 1), "rmse_zoh_m", 1, "rmse_cv_m", 0.5, ...
                "nrmse_zoh", 1, "nrmse_cv", 0.5, "max_error_zoh_m", 1, ...
                "max_error_cv_m", 0.5, "performance_ratio", 0.5, "improvement_percent", 50, ...
                "mean_packet_age_s", delay + 0.01, "omega_delay", omega * delay, ...
                "omega_mean_packet_age", omega * (delay + 0.01), "omega_time_constant", omega * 0.1, ...
                "omega_sample_period", omega * 0.02, ...
                "zero_tolerance_m", 32 * eps(max([1, 1, 0.5])));
            config = struct("trajectory", struct("type", trajectory, "amplitude", 1, "omega", omega), ...
                "evaluation", struct("total_cycles", 10, "warmup_cycles", 2), ...
                "communication", struct("delay", delay, "sample_period", 0.02), ...
                "plant", struct("time_constant", 0.1), "simulation", struct("dt", 0.005, ...
                "fixed_step", 0.005, "duration", 0.2, "solver", "ode4"));
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
