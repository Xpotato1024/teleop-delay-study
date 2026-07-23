function contract = architecture_contract()
% architecture_contract  Return the fixed system-figure node/edge contract.

nodes = [
    "continuous_target"
    "sender_sampling"
    "fixed_delay"
    "latest_packet"
    "zoh_reconstruction"
    "cv_reconstruction"
    "reference_plant"
    "zoh_plant"
    "cv_plant"
    "evaluation"].';
labels = [
    "連続目標軌道 r(t)"
    "送信側サンプリング"
    "固定通信遅延 L"
    "利用可能な最新パケット" + newline + "送信時刻・位置・速度" + newline + "有効状態・パケット齢"
    "ZOH再構成"
    "定速度予測（CV）再構成"
    "参照プラント" + newline + "一次遅れモデル"
    "ZOHプラント" + newline + "一次遅れモデル"
    "CVプラント" + newline + "一次遅れモデル"
    "参照出力との" + newline + "誤差評価"].';
requiredEdges = [
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
forbiddenEdges = [
    "zoh_reconstruction" "reference_plant"
    "cv_reconstruction" "reference_plant"
    "fixed_delay" "reference_plant"
    "latest_packet" "reference_plant"];
contract = struct( ...
    "nodes", nodes, ...
    "labels", labels, ...
    "required_edges", requiredEdges, ...
    "forbidden_edges", forbiddenEdges, ...
    "plant_model", "3つのプラントは同一の一次遅れモデル", ...
    "evaluation_note", "ZOH/CV出力を参照プラント出力と比較", ...
    "title", "通信遅延と定速度予測補償のシステム構成", ...
    "caption", "連続目標軌道は通信経路と参照経路に分岐する。ZOHおよびCVで再構成した指令に対するプラント出力を、通信を介さない参照プラント出力と比較する。");
end
