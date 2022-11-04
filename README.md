# react-native-facetec

React Native Facetec integration

## Installation

```sh
npm install react-native-facetec
```

## Usage

```js
import { FacetecConfig, initialize } from 'react-native-facetec';

// ...
const config: FacetecConfig = {
  key: '',
  deviceKeyIdentifier: '',
  token: '',
  publicFaceScanEncryptionKey: '',
};

const App: FC = () => {
  useEffect(() => {
    initialize(config).then(console.log);
  }, []);
};
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
