import { openBrowserAsync, WebBrowserPresentationStyle } from 'expo-web-browser';
import { Pressable, Text, Linking } from 'react-native';
import { type ComponentProps } from 'react';

type Props = Omit<ComponentProps<typeof Pressable>, 'onPress'> & { href: string };

export function ExternalLink({ href, children, ...rest }: Props) {
  return (
    <Pressable
      {...rest}
      onPress={async (event) => {
        if (process.env.EXPO_OS !== 'web') {
          // Prevent the default behavior of linking to the default browser on native.
          event.preventDefault();
          // Open the link in an in-app browser.
          await openBrowserAsync(href, {
            presentationStyle: WebBrowserPresentationStyle.AUTOMATIC,
          });
        } else {
          Linking.openURL(href);
        }
      }}
    >
      <Text style={{ color: "#1E88E5", fontWeight: "600" }}>{children}</Text>
    </Pressable>
  );
}
