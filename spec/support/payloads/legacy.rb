{
  type: 'test',
  build: {
    id: 385899,
    number: '688.1',
    commit: '47b9d471cdec248a9f6d2f44e66b99c85637d1bd',
    commit_range: '2c2a43cc0102...47b9d471cdec',
    branch: 'master',
    ref: nil,
    state: 'created',
    pull_request: false
  },
  job: {
    id: 385899,
    number: '688.1',
    commit: '47b9d471cdec248a9f6d2f44e66b99c85637d1bd',
    commit_range: '2c2a43cc0102...47b9d471cdec',
    branch: 'master',
    ref: nil,
    state: 'created',
    pull_request: false
  },
  source: {
    id: 385898,
    number: '688'
  },
  repository: {
    id: 4806,
    slug: 'travis-rep
    os/test-project-matrix-1',
    source_url: 'git://github.com/travis-repos/test-project-matrix-1.git',
    last_build_id: 385898,
    last_build_number: '688',
    last_build_started_at: '2013-01-17T19:31:12Z',
    last_build_finished_at: '2013-01-17T19:32:23Z',
    last_build_duration: 109,
    last_build_state: 'passed',
    description: 'Test dummy repository for testing Travis CI'
  },
  config: {
    script: 'ruby -e \'p RUBY_VERSION\'; true && rake test',
    after_script: ['echo $TRAVIS_JOB_ID'],
    rvm: '1.9.3',
    matrix: {
      allow_failures: [{ rvm: '1.9.3' }]
    },
    before_script: ['rvm list'],
    branches: { only: 'master' },
    notifications: { email: false, },
  },
  queue: 'builds.common',
  uuid: 'f7631120-453e-4363-8cae-805c4e431d00'
}

