import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "utils.js" as Utils
import QtQuick.Controls.Material 2.2

ColumnLayout {
    objectName: "interfaces"
    Component.onCompleted: load()
    function load() {
        otp.checked = Utils.includes(yubiKey.enabledUsbInterfaces, 'OTP')
        fido.checked = Utils.includes(yubiKey.enabledUsbInterfaces, 'FIDO')
        ccid.checked = Utils.includes(yubiKey.enabledUsbInterfaces, 'CCID')
    }

    function getEnabledInterfaces() {
        var interfaces = []
        if (otp.checked) {
            interfaces.push('OTP')
        }
        if (fido.checked) {
            interfaces.push('FIDO')
        }
        if (ccid.checked) {
            interfaces.push('CCID')
        }
        return interfaces
    }

    function configureInterfaces() {
        yubiKey.set_mode(getEnabledInterfaces(), function (error) {
            if (error) {
                console.log(error)
            } else {
                if (!yubiKey.canWriteConfig) {
                    reInsertYubiKey.open()
                } else {
                    views.pop()
                }
            }
        })
    }

    function configurationHasChanged() {
        var enabledYubiKeyUsbInterfaces = JSON.stringify(
                    yubiKey.enabledUsbInterfaces.sort())
        var enabledUiUsbInterfaces = JSON.stringify(
                    getEnabledInterfaces().sort())
        return enabledYubiKeyUsbInterfaces !== enabledUiUsbInterfaces
    }

    function validCombination() {
        return otp.checked || fido.checked || ccid.checked
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: constants.contentMargins
        Layout.topMargin: constants.contentTopMargin
        Layout.bottomMargin: constants.contentBottomMargin
        Layout.preferredHeight: constants.contentHeight
        Layout.maximumHeight: constants.contentHeight
        Layout.preferredWidth: constants.contentWidth
        Layout.maximumWidth: constants.contentWidth

        ColumnLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Heading1 {
                text: qsTr("Interfaces")
            }

            BreadCrumbRow {
                BreadCrumb {
                    text: qsTr("Home")
                    action: views.home
                }

                BreadCrumbSeparator {
                }

                BreadCrumb {
                    text: qsTr("Interfaces")
                    active: true
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
            id: mainRow

            GridLayout {
                columns: 3
                RowLayout {
                    Layout.columnSpan: 3
                    Label {
                        text: qsTr("USB")
                        color: yubicoBlue
                        font.pointSize: constants.h2
                    }
                    Image {
                        fillMode: Image.PreserveAspectCrop
                        source: "../images/usb.svg"
                        sourceSize.width: 24
                        sourceSize.height: 24
                    }
                }
                CheckBox {
                    id: otp
                    enabled: yubiKey.otpInterfaceSupported()
                    text: qsTr("OTP")
                    font.pointSize: constants.h3
                    checkable: true
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Toggle OTP interface over USB")
                    Material.foreground: yubicoBlue
                }
                CheckBox {
                    id: fido
                    enabled: yubiKey.fidoInterfaceSupported()
                    text: qsTr("FIDO")
                    font.pointSize: constants.h3
                    checkable: true
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Toggle FIDO interface over USB")
                    Material.foreground: yubicoBlue
                }
                CheckBox {
                    id: ccid
                    enabled: yubiKey.ccidInterfaceSupported()
                    text: qsTr("CCID (Smart Card)")
                    font.pointSize: constants.h3
                    checkable: true
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Toggle CCID interface over USB")
                    Material.foreground: yubicoBlue
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            Button {
                enabled: configurationHasChanged() && validCombination()
                text: qsTr("Save Interfaces")
                highlighted: true
                onClicked: configureInterfaces()
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Finish and save interfaces configuration to YubiKey")
                icon.source: "../images/finish.svg"
                icon.width: 16
                icon.height: 16
                font.capitalization: Font.MixedCase
                font.family: constants.fontFamily
            }
        }
    }
}
