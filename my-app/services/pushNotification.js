import * as Notifications from "expo-notifications";
import * as Device from "expo-device";
import Constants from "expo-constants";

Notifications.setNotificationHandler({
    handleNotification: async () => ({
        shouldShowBanner: true,
        shouldShowList: true,
        shouldPlaySound: true,
        shouldSetBadge: true,
    }),
});

export async function registerForPushNotificationsAsync() {
    if (!Device.isDevice) {
        console.log("KHONG PHAI THIET BI THAT");
        return null;
    }

    const { status: existingStatus } = await Notifications.getPermissionsAsync();
    let finalStatus = existingStatus;

    if (existingStatus !== "granted") {
        const { status } = await Notifications.requestPermissionsAsync();
        finalStatus = status;
    }

    console.log("NOTIFICATION PERMISSION =", finalStatus);

    if (finalStatus !== "granted") {
        return null;
    }

    const projectId =
        Constants.expoConfig?.extra?.eas?.projectId ??
        Constants.easConfig?.projectId;

    console.log("PROJECT ID =", projectId);

    const token = (
        await Notifications.getExpoPushTokenAsync({ projectId })
    ).data;

    return token;
}