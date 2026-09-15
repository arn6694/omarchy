/***************************************************************************
* Copyright (c) 2013 Abdurrahman AVCI <abdurrahmanavci@gmail.com>
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without restriction,
* including without limitation the rights to use, copy, modify, merge,
* publish, distribute, sublicense, and/or sell copies of the Software,
* and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
* OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
* OR OTHER DEALINGS IN THE SOFTWARE.
*
***************************************************************************/

import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    id: container
    width: 640
    height: 480

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.index

    TextConstants { id: textConstants }

    Connections {
        target: sddm

        function onLoginSucceeded() {
            errorMessage.color = "steelblue"
            errorMessage.text = textConstants.loginSucceeded
        }
        function onLoginFailed() {
            password.text = ""
            errorMessage.color = "red"
            errorMessage.text = textConstants.loginFailed
        }
        function onInformationMessage(message) {
            errorMessage.color = "red"
            errorMessage.text = message
        }
    }

    Background {
        anchors.fill: parent
        source: Qt.resolvedUrl(config.background)
        fillMode: Image.PreserveAspectCrop
        onStatusChanged: {
            var defaultBackground = Qt.resolvedUrl(config.defaultBackground)
            if (status == Image.Error && source != defaultBackground) {
                source = defaultBackground
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        //visible: primaryScreen

        Text {
            anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 40
            color: "white"; font.pixelSize: 48
            property date now: new Date()
            text: Qt.formatDateTime(now, "h:mm AP")
            Timer { interval: 1000; running: true; repeat: true; onTriggered: parent.now = new Date() }
        }

        Rectangle {
            id: rectangle
            anchors.verticalCenter: parent.verticalCenter
            x: parent.width >= 1000 ? parent.width * 0.06 : (parent.width - width) / 2
            width: 460
            height: mainColumn.implicitHeight + 64

            color: "#dd16191d"; radius: 20; border.color: "#605e666e"

            Column {
                id: mainColumn
                width: parent.width - 64
                anchors.centerIn: parent
                spacing: 12
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    height: text.implicitHeight
                    width: parent.width
                    text: "OMADORA"
                    wrapMode: Text.WordWrap
                    font.pixelSize: 24
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }

                Column {
                    width: parent.width
                    spacing: 4
                    Text {
                        id: lblName
                        width: parent.width
                        text: textConstants.userName
                        font.bold: true
                        color: "#eeeeee"
                        font.pixelSize: 15
                    }

                    TextBox {
                        id: name
                        width: parent.width; height: 44
                        text: userModel.lastUser
                        font.pixelSize: 17

                        KeyNavigation.backtab: rebootButton; KeyNavigation.tab: password

                        Keys.onPressed: function (event) {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, sessionIndex)
                                event.accepted = true
                            }
                        }
                    }
                }

                Column {
                    width: parent.width
                    spacing : 4
                    Text {
                        id: lblPassword
                        width: parent.width
                        text: textConstants.password
                        font.bold: true
                        color: "#eeeeee"
                        font.pixelSize: 15
                    }

                    PasswordBox {
                        id: password
                        width: parent.width; height: 44
                        font.pixelSize: 17

                        KeyNavigation.backtab: name; KeyNavigation.tab: session

                        Keys.onPressed: function (event) {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, sessionIndex)
                                event.accepted = true
                            }
                        }
                    }
                }

                Column {
                    spacing: 12
                    width: parent.width
                    z: 100

                    Column {
                        z: 100
                        width: parent.width
                        spacing : 4

                        Text {
                            id: lblSession
                            width: parent.width
                            text: textConstants.session
                            wrapMode: TextEdit.WordWrap
                            font.bold: true
                            color: "#eeeeee"
                        font.pixelSize: 15
                        }

                        ComboBox {
                            id: session
                            width: parent.width; height: 44
                            font.pixelSize: 17

                            arrowIcon: Qt.resolvedUrl("angle-down.png")

                            model: sessionModel
                            index: sessionModel.lastIndex

                            KeyNavigation.backtab: password; KeyNavigation.tab: layoutBox
                        }
                    }

                    Column {
                        z: 101
                        width: parent.width
                        spacing : 4

                        visible: keyboard.enabled && keyboard.layouts.length > 0

                        Text {
                            id: lblLayout
                            width: parent.width
                            text: textConstants.layout
                            wrapMode: TextEdit.WordWrap
                            font.bold: true
                            color: "#eeeeee"
                        font.pixelSize: 15
                        }

                        LayoutBox {
                            id: layoutBox
                            width: parent.width; height: 44
                            font.pixelSize: 17

                            arrowIcon: Qt.resolvedUrl("angle-down.png")

                            KeyNavigation.backtab: session; KeyNavigation.tab: loginButton
                        }
                    }
                }

                Column {
                    width: parent.width
                    Text {
                        id: errorMessage
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: textConstants.prompt
                        color: "#dddddd"
                        font.pixelSize: 13
                    }
                }

                Row {
                    spacing: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                    property int btnWidth: Math.max(loginButton.implicitWidth,
                                                    shutdownButton.implicitWidth,
                                                    rebootButton.implicitWidth, 80) + 8
                    Button {
                        id: loginButton
                        text: textConstants.login
                        width: parent.btnWidth

                        onClicked: sddm.login(name.text, password.text, sessionIndex)

                        KeyNavigation.backtab: layoutBox; KeyNavigation.tab: shutdownButton
                    }

                    Button {
                        id: shutdownButton
                        text: textConstants.shutdown
                        width: parent.btnWidth

                        onClicked: sddm.powerOff()

                        KeyNavigation.backtab: loginButton; KeyNavigation.tab: rebootButton
                    }

                    Button {
                        id: rebootButton
                        text: textConstants.reboot
                        width: parent.btnWidth

                        onClicked: sddm.reboot()

                        KeyNavigation.backtab: shutdownButton; KeyNavigation.tab: name
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        if (name.text == "")
            name.focus = true
        else
            password.focus = true
    }
}
