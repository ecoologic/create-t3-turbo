const fs = require("fs");

module.exports = async function downloadBaselineCoverage({ github, context, core }) {
  const artifactPath = process.env.BASELINE_ARTIFACT_PATH;
  if (!artifactPath) {
    throw new Error("BASELINE_ARTIFACT_PATH env var is required.");
  }

  const { owner, repo } = context.repo;
  const runs = await github.rest.actions.listWorkflowRuns({
    owner,
    repo,
    workflow_id: "ci.yml",
    branch: "main",
    status: "success",
    per_page: 5,
  });

  const run = runs.data.workflow_runs.find(Boolean);
  if (!run) {
    core.warning("Unable to find a successful main run with coverage artifact.");
    core.setOutput("found", "false");
    return;
  }

  const artifacts = await github.rest.actions.listWorkflowRunArtifacts({
    owner,
    repo,
    run_id: run.id,
    per_page: 50,
  });

  const artifact = artifacts.data.artifacts.find(
    (candidate) => candidate.name === "nextjs-coverage-summary",
  );

  if (!artifact) {
    core.warning(
      `No nextjs-coverage-summary artifact found on run id ${run.id} (${run.html_url}).`,
    );
    core.setOutput("found", "false");
    return;
  }

  const download = await github.rest.actions.downloadArtifact({
    owner,
    repo,
    artifact_id: artifact.id,
    archive_format: "zip",
  });

  const buffer = Buffer.from(download.data);
  await fs.promises.writeFile(artifactPath, buffer);
  core.info(`Downloaded baseline coverage from run ${run.id}.`);
  core.setOutput("found", "true");
  core.setOutput("zip", artifactPath);
};
