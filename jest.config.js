module.exports = {
  testEnvironment: 'jsdom',
  roots: ['<rootDir>/app/javascript'],
  testMatch: ['**/__tests__/**/*.js', '**/?(*.)+(spec|test).js'],
  moduleNameMapper: {
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
  },
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  collectCoverageFrom: [
    'app/javascript/**/*.js',
    '!app/javascript/**/*.test.js',
    '!app/javascript/**/*.spec.js',
  ],
};
