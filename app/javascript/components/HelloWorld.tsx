import * as React from "react";

interface Props {
    greetinga: string
}

const HelloWorld = (props: Props) => (
    <React.Fragment>
        Greetinga: {props.greetinga}
    </React.Fragment>
)

export default HelloWorld;
